{%- set file = '/etc/sysconfig/services' %}

profile_services_header:
  suse_sysconfig.header:
    - name: {{ file }}
    - fillup: services-rpm

profile_services_config:
  file.keyvalue:
    - name: {{ file }}
    - ignore_if_missing: {{ opts['test'] }}
    - key_values:
        DISABLE_RESTART_ON_UPDATE: '"{{ 'no' if grains.get('reboot_safe', true) else 'yes' }}"'
        DISABLE_STOP_ON_REMOVAL: '"no"'
