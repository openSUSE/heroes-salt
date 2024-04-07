{%- set file = '/etc/sysconfig/services' %}
{%- set roles = pillar.get('roles', []) %}

profile_services_header:
  suse_sysconfig.header:
    - name: {{ file }}
    - fillup: services-rpm

profile_services_config:
  file.keyvalue:
    - name: {{ file }}
    - ignore_if_missing: {{ opts['test'] }}
    - key_values:
        DISABLE_RESTART_ON_UPDATE: '"{{ 'yes' if 'hypervisor.cluster' in roles or 'mariadb' in roles else 'no' }}"'
        DISABLE_STOP_ON_REMOVAL: '"no"'
