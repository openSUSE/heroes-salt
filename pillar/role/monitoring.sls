{% set osrelease = salt['grains.get']('osrelease') %}

{%- if osrelease == '15.5' %}
profile:
  monitoring:
    check_zypper:
      whitelist:
        - fping
        - golang-github-prometheus-node_exporter
        - golang-github-prometheus-prometheus
        - grafana
        - influxdb
        - libdbi-drivers-dbd-mysql
        - libdbi-drivers-dbd-pgsql
        - libdbi-drivers-dbd-sqlite3
        - libgearman8
        - libzmq5
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
        - monitoring-plugins-nfsmounts
        - monitoring-plugins-nis
        - monitoring-plugins-nrpe
        - monitoring-plugins-nt
        # do the ntp_ ones work with chrony ?
        - monitoring-plugins-ntp_peer
        - monitoring-plugins-ntp_time
        - monitoring-plugins-nwstat
        - monitoring-plugins-oracle
        - monitoring-plugins-overcr
        - monitoring-plugins-pdns
        - monitoring-plugins-pgsql
        - monitoring-plugins-ping
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
        - nrpe
        - percona-nagios-plugins
        - perl-Array-Unique
        - perl-CGI
        - perl-Config-Tiny
        - perl-Convert-ASN1
        - perl-Crypt-X509
        - perl-File-Slurp
        - perl-JSON-Parse
        - perl-Math-Calc-Units
        - perl-Monitoring-Plugin
        - perl-Nagios-Plugin
        - perl-Number-Format
{%- endif %}

sudoers:
  included_files:
    /etc/sudoers.d/group_monitoring-admins:
      groups:
        monitoring-admins:
          - 'ALL=(ALL) ALL'
