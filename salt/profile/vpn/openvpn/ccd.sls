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

{%- set dir_etc       = '/etc/openvpn/' %}
{%- set dir_tcp       = dir_etc ~ 'ccd-tcp/' %}
{%- set dir_udp       = dir_etc ~ 'ccd-udp/' %}
{%- set check_cmd     = 'grep -hoP "::\K(\d{2,4})" ' ~ dir_tcp %}

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
        {%- set number =
              salt['cmd.run'](
                check_cmd ~ user
              )
        %}
        {%- else %}
        {%- set number =
              salt['cmd.shell'](
                check_cmd ~ '*|sort|tail -n1'
              )
        %}
        {%- endif %}
        {%- do salt.log.debug('vpn.ccd: number for user ' ~ user ~ ' set to ' ~ number) %}

      - {{ dir_tcp }}{{ user }}:
        - context:
            prefix: '2a07:de40:b27e:5002::'
            number: {{ number }}
      - {{ dir_udp }}{{ user }}:
        - context:
            prefix: '2a07:de40:b27e:5001::'
            number: {{ number }}
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
