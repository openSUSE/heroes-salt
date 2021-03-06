{% set osrelease = salt['grains.get']('osrelease') %}
profile:
  monitoring:
    check_zypper:
      whitelist:
        - GeoIP-data
        - check_mk
        - check_mk-agent
        - check_mk-agent-apache_status
        - check_mk-multisite
        - check_postgres
        - fping
        - gearmand-server
        - gearmand-server-sqlite3
        - gearmand-tools
        - golang-github-prometheus-node_exporter
        - golang-github-prometheus-prometheus
        - grafana
        - icinga
        - icinga-doc
        - icinga-plugins-eventhandlers
        - icinga-www
        - icinga-www-config
        - influxdb
        - kohana2
        - koseven
        - libGeoIP1
        - libdbi-drivers-dbd-mysql
        - libdbi-drivers-dbd-pgsql
        - libdbi-drivers-dbd-sqlite3
        - libdbi3
        - libgearman8
        - libzmq5
        - mk-livestatus
        - monitoring-eventhandlers-send_messages
        - monitoring-plugins
        - monitoring-plugins-all
        - monitoring-plugins-bind
        - monitoring-plugins-bind9
        - monitoring-plugins-bonding
        - monitoring-plugins-breeze
        - monitoring-plugins-by_ssh
        - monitoring-plugins-clamav
        - monitoring-plugins-cluster
        - monitoring-plugins-common
        - monitoring-plugins-contentage
        - monitoring-plugins-cups
        - monitoring-plugins-dbi
        - monitoring-plugins-dbi-mysql
        - monitoring-plugins-dbi-pgsql
        - monitoring-plugins-dbi-sqlite3
        - monitoring-plugins-dhcp
        - monitoring-plugins-dig
        - monitoring-plugins-disk
        - monitoring-plugins-disk_smb
        - monitoring-plugins-diskio
        - monitoring-plugins-dns
        - monitoring-plugins-dummy
        - monitoring-plugins-extras
        - monitoring-plugins-file_age
        - monitoring-plugins-flexlm
        - monitoring-plugins-fping
        - monitoring-plugins-gitlab
        - monitoring-plugins-hpasm
        - monitoring-plugins-hpjd
        - monitoring-plugins-http
        - monitoring-plugins-icmp
        - monitoring-plugins-ide_smart
        - monitoring-plugins-ifoperstatus
        - monitoring-plugins-ifstatus
        - monitoring-plugins-ipmi-sensor1
        - monitoring-plugins-ircd
        - monitoring-plugins-ldap
        - monitoring-plugins-load
        - monitoring-plugins-log
        - monitoring-plugins-mailq
        - monitoring-plugins-maintenance
        - monitoring-plugins-mem
        - monitoring-plugins-mrtg
        - monitoring-plugins-mrtgtraf
        - monitoring-plugins-mysql
        - monitoring-plugins-nagios
        - monitoring-plugins-nagiostats
        - monitoring-plugins-nfsmounts
        - monitoring-plugins-nis
        - monitoring-plugins-nrpe
        - monitoring-plugins-nt
        - monitoring-plugins-ntp_peer
        - monitoring-plugins-ntp_time
        - monitoring-plugins-nwstat
        - monitoring-plugins-oracle
        - monitoring-plugins-overcr
        - monitoring-plugins-pdns
        - monitoring-plugins-pgsql
        - monitoring-plugins-ping
        - monitoring-plugins-pnp_rrds
        - monitoring-plugins-postgres
        - monitoring-plugins-procs
        - monitoring-plugins-qlogic_sanbox
        - monitoring-plugins-rabbitmq
        - monitoring-plugins-radius
        - monitoring-plugins-real
        - monitoring-plugins-repomd
        - monitoring-plugins-rpc
        - monitoring-plugins-sensors
        - monitoring-plugins-sks_keyserver
        - monitoring-plugins-smtp
        - monitoring-plugins-snmp
        - monitoring-plugins-ssh
        - monitoring-plugins-ssl_validity
        - monitoring-plugins-swap
        - monitoring-plugins-systemd_service
        - monitoring-plugins-tcp
        - monitoring-plugins-time
        - monitoring-plugins-ups
        - monitoring-plugins-ups_alarm
        - monitoring-plugins-users
        - monitoring-plugins-wave
        - monitoring-plugins-webpage_sync
        - monitoring-plugins-x224
        - monitoring-plugins-zypper
        - monitoring-tools
        - mrtg
        - nagios-business-process-addon
        - nrpe
        - percona-nagios-plugins
        - perl-Array-Unique
        - perl-CGI
        - perl-Class-Accessor
        - perl-Config-Tiny
        - perl-Convert-ASN1
        - perl-Crypt-X509
        - perl-File-Slurp
        - perl-JSON-Parse
        - perl-Math-Calc-Units
        - perl-Monitoring-Plugin
        - perl-Nagios-Plugin
        - perl-Net-SNMP
        - perl-Number-Format
        - perl-Test-Exception
        - php5-ZendFramework
        - pnp4nagios
        - pnp4nagios-icinga
        - python2-pycrypto
        - python3-pycrypto
sudoers:
  included_files:
    /etc/sudoers.d/group_monitoring-admins:
      groups:
        monitoring-admins:
          - 'ALL=(ALL) ALL'
