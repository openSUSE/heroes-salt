{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == '42.3' %}
profile:
  monitoring:
    check_zypper:
      whitelist:
        - elasticsearch
        - fping
        - gearmand-server
        - gearmand-server-sqlite3
        - gearmand-tools
        - jruby-1_7_25
        - kibana
        - kohana2
        - libdbi-drivers-dbd-mysql
        - libdbi-drivers-dbd-pgsql
        - libdbi-drivers-dbd-sqlite3
        - libgearman8
        - libyajl2
        - logstash
        - monitoring-eventhandlers-send_messages
        - monitoring-plugins-bind
        - monitoring-plugins-clamav
        - monitoring-plugins-diskio
        - monitoring-plugins-hpasm
        - monitoring-plugins-ipmi-sensor1
        - monitoring-plugins-maintenance
        - monitoring-plugins-nagiostats
        - monitoring-plugins-nfsmounts
        - monitoring-plugins-pnp_rrds
        - monitoring-plugins-qlogic_sanbox
        - monitoring-plugins-repomd
        - monitoring-plugins-ssl_validity
        - monitoring-plugins-ups_alarm
        - monitoring-plugins-x224
        - mrtg
        - nagios-business-process-addon
        - nagios-xen-host
        - percona-nagios-plugins
        - perl-Array-Unique
        - perl-Config-Tiny
        - perl-Crypt-X509
        - perl-File-Slurp
        - perl-JSON-Parse
        - perl-Math-Calc-Units
        - perl-Monitoring-Plugin
        - perl-Number-Format
        - php5-ZendFramework
        - pnp4nagios
        - pnp4nagios-icinga
{% endif %}
sudoers:
  included_files:
    /etc/sudoers.d/group_monitoring-admins:
      groups:
        monitoring-admins:
          - 'ALL=(ALL) ALL'
