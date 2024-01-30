{%- set roles = pillar.get('roles', []) %}

/etc/sysconfig/services:
  file.managed:
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - DISABLE_RESTART_ON_UPDATE="{{ 'yes' if 'hypervisor.cluster' in roles or 'mariadb' in roles else 'no' }}"
        - DISABLE_STOP_ON_REMOVAL="no"
