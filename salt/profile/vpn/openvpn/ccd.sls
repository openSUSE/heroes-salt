{%- set users =
      salt['ldap3.search'](
        {"url": "ldaps://freeipa.infra.opensuse.org"},
        base='cn=groups,cn=compat,dc=infra,dc=opensuse,dc=org',
        scope='onelevel',
        filterstr='cn=vpn',
        attrlist=["memberUid"]
      ).get(
        'cn=vpn,cn=groups,cn=compat,dc=infra,dc=opensuse,dc=org', {}
      ).get(
        'memberUid', []
      )
%}
{%- set prefixes = {
      'tcp': '2a07:de40:b27e:5002::',
      'udp': '2a07:de40:b27e:5001::',
    }
%}

{%- set dir_etc       = '/etc/openvpn/' %}
{%- set dir_tcp       = dir_etc ~ 'ccd-tcp/' %}
{%- set dir_udp       = dir_etc ~ 'ccd-udp/' %}
{%- set check_cmd     = 'awk "/^ifconfig/{ print $2 }" ' %}

{%- set desired_ccds  = [] %}
{%- set existing_ccds = salt['file.find'](dir_etc ~ 'ccd-*', type='f', print='name') | unique | sort %}

openvpn_ccd_directories:
  file.directory:
    - names:
      - {{ dir_tcp }}
      - {{ dir_udp }}


openvpn_ccd_files:
  file.managed:
    - names:

      {%- for user in users | sort %}
        {%- set user = user.decode() %}
        {%- do desired_ccds.append(user) %}
        {%- if
              salt['file.file_exists'](dir_tcp ~ user)
              and
              salt['file.file_exists'](dir_udp ~ user)
        %}
        {%- set addresses = {
              'tcp': salt['cmd.run'](
                 check_cmd ~ dir_tcp ~ user
              ),
              'udp': salt['cmd.run'](
                 check_cmd ~ dir_udp ~ user
              ),
            }
        %}
        {%- else %}
        {%- set addresses = {
              'tcp': salt['os_network.sixify'](
                user, prefixes['tcp']
              ),
              'udp': salt['os_network.sixify'](
                user, prefixes['udp']
              ),
            }
        %}
        {%- endif %}

      - {{ dir_tcp }}{{ user }}:
        - context:
            address: {{ addresses['tcp'] }}
            prefix: '{{ prefixes['tcp'] }}'
      - {{ dir_udp }}{{ user }}:
        - context:
            address: {{ addresses['udp'] }}
            prefix: '{{ prefixes['udp'] }}'
      {%- endfor %}

    - source: salt://profile/vpn/openvpn/files/ccd.jinja
    - template: jinja
    - require:
      - file: openvpn_ccd_directories

{%- set bad_ccds = existing_ccds | difference(desired_ccds) %}
{%- if bad_ccds %}
openvpn_ccd_bad_files:
  file.absent:
    - names:
      {%- for user in bad_ccds %}
      - {{ dir_tcp }}{{ user }}
      - {{ dir_udp }}{{ user }}
      {%- endfor %}
{%- endif %}
