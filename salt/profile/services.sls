{%- set roles = pillar.get('roles', []) %}

/etc/sysconfig/services:
  file.managed:
    - contents: |
        ## Path:	System/Services
        {{ pillar['managed_by_salt_sysconfig'] | indent(8) }}

        ## Type:        yesno
        ## Default:     no
        #
        # Do you want to disable the automatic restart of services when
        # a new version gets installed?
        #
        DISABLE_RESTART_ON_UPDATE="{{ 'yes' if 'hypervisor.cluster' in roles or 'mariadb' in roles else 'no' }}"

        ## Type:        yesno
        ## Default:     no
        #
        # Do you want to disable the automatic shutdown of services when
        # the corresponding package gets erased?
        #
        DISABLE_STOP_ON_REMOVAL="no"
