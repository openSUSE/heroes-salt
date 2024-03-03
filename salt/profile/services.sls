{%- set file = '/etc/sysconfig/services' %}
{%- set fillup_header = '## Path:\tSystem/Services\n' %}
{%- set salt_header = pillar['managed_by_salt_sysconfig'] %}
{%- set test = opts['test'] %}
{%- set roles = pillar.get('roles', []) %}

profile_services_header:
  file.replace:
    - name: {{ file }}
    - ignore_if_missing: {{ test }}
    - pattern: {{ ( '^' ~ fillup_header ~ '(?:' ~ salt_header ~ ')?' ) | yaml_encode }}
    - repl: {{ ( fillup_header ~ salt_header ) | yaml_encode }}
    - count: 1
    - bufsize: file

profile_services_config:
  file.keyvalue:
    - name: {{ file }}
    - ignore_if_missing: {{ test }}
    - key_values:
        DISABLE_RESTART_ON_UPDATE: '"{{ 'yes' if 'hypervisor.cluster' in roles or 'mariadb' in roles else 'no' }}"'
        DISABLE_STOP_ON_REMOVAL: '"no"'
