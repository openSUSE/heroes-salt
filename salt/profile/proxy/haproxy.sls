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

haproxy_errorfiles:
  file.recurse:
    - name: /etc/haproxy/errorfiles
    - source: salt://{{ slspath }}/files/etc/haproxy/errorfiles
    - clean: true
    - template: jinja
    - require:
      - haproxy.install
    - watch_in:
      - service: haproxy.service

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
    - watch:
      - service: haproxy.service
{%- else %}
{%- do salt.log.debug('Skipping management of HAProxy secrets!') %}
{%- endif %}
