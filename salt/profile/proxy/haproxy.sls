include:
  - haproxy

haproxy_sysconfig:
  file.managed:
    - name: /etc/sysconfig/haproxy
    - mode: '0600'
    - replace: false

haproxy_dhparam:
  cmd.run:
    - name: openssl dhparam -out /etc/haproxy/dhparam 2048
    - unless: test -f /etc/haproxy/dhparam
    - watch_in:
      - service: haproxy.service

haproxy_trees:
  file.recurse:
    - names:
        - /etc/haproxy/blacklists:
            - source: salt://{{ slspath }}/files/etc/haproxy/blacklists
        - /etc/haproxy/errorfiles:
            - source: salt://{{ slspath }}/files/etc/haproxy/errorfiles
        {%- if grains['host'].rstrip('12') in [
              'atlas',
              'globus',
            ] or 'runner' in grains['host'] or grains.get('CI_TEST_RUN')
        %}
        - /etc/haproxy/robots:
            - source: salt://{{ slspath }}/files/etc/haproxy/robots
        {%- endif %}
    - clean: true
    - template: jinja
    - require:
      - haproxy.install
    - watch_in:
      - service: haproxy.service

{%- set goodbots = salt['pillar.get']('profile:proxy:haproxy:goodbots', []) %}
{%- if goodbots %}
haproxy_allowlists:
  file.directory:
    - name: /etc/haproxy/allowlists

haproxy_allowlists_networks:
  file.directory:
    - name: /etc/haproxy/allowlists/networks
    - require:
        - file: haproxy_allowlists

{%- for bot in goodbots %}
haproxy_goodbot_{{ bot['name'] }}:
  file.managed:
    - name: /etc/haproxy/allowlists/networks/{{ bot['name'] }}
    - contents: {{ bot['remote_addresses'] }}
    - require:
        - file: haproxy_allowlists_networks
{%- endfor %}
{%- else %}
haproxy_allowlists:
  file.absent:
    - name: /etc/haproxy/allowlists
{%- endif %}

{%- set secrets = salt['pillar.get']('profile:proxy:haproxy:secrets', {}) %}
{%- if 'stats_user' in secrets and 'stats_passphrase' in secrets and salt['grains.get']('include_secrets', True) %}
haproxy_sysconfig_variables:
  file.keyvalue:
    - name: /etc/sysconfig/haproxy
    - append_if_not_found: true
    - show_changes: false
    - key_values:
        STATS_USER: {{ secrets['stats_user'] }}
        STATS_PASSPHRASE: {{ secrets['stats_passphrase'] }}
    - require:
      - file: haproxy_sysconfig
    - watch_in:
      - service: haproxy.service
{%- else %}
{%- do salt.log.debug('Skipping management of HAProxy secrets!') %}
{%- endif %}

{%- if salt['pillar.get']('profile:proxy:haproxy:geoip', false) is sameas true %}
haproxy_geoip_directory:
  file.directory:
    - name: /var/lib/haproxy/geoip
    - require:
      - haproxy.install

haproxy_geoip_config:
  file.managed:
    - name: /etc/haproxy/geoip.lua
    - source: salt://{{ slspath }}/files/etc/haproxy/geoip.lua.jinja
    - template: jinja
    - require:
      - haproxy.install
      - file: haproxy_geoip_directory
    - watch_in:
      - service: haproxy.service

{%- else %}

haproxy_geoip:
  file.absent:
    - names:
        - /var/lib/haproxy/geoip
        - /etc/haproxy/geoip.lua
    - watch:
      - service: haproxy.service
{%- endif %}
