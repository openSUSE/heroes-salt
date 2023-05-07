include:
  - haproxy

haproxy_sysconfig:
  file.managed:
    - name: /etc/sysconfig/haproxy
    - mode: '0640'

{%- if salt['grains.get']('include_secrets', True) %}
{%- set secrets = salt['pillar.get']('profile:proxy:haproxy:secrets') %}
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
{%- do salt.log.warning('Skipping management of HAProxy secrets!') %}
{%- endif %}
