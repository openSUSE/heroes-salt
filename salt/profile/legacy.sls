remove_decommissioned_packages:
  pkg.removed:
    - pkgs:
        - cpupower
        - ethtool
        - golang-github-justwatchcom-elasticsearch_exporter
        - libcpupower1
        - libpci3
        - libpolkit-agent-1-0
        - libpolkit-gobject-1-0
        - polkit
        - python3-configobj
        - python3-linux-procfs
        - python3-pyudev
        {%- if grains['osfullname'] != 'Leap' %}
        - python3-six
        {%- endif %}
        - suse-online-update
        - tuned
        - virt-what
        {%- if grains['virtual'] != 'physical' %}
        - hdparm
        - mdadm
        {%- endif %}
        - libipmimonitoring6
        - monitoring-eventhandlers-send_messages
        - monitoring-plugins
        - monitoring-plugins-all
        - monitoring-plugins-apache_status
        - monitoring-plugins-bind
        - monitoring-plugins-bind9
        - monitoring-plugins-bonding
        - monitoring-plugins-breeze
        - monitoring-plugins-by_ssh
        - monitoring-plugins-cluster
        - monitoring-plugins-common
        - monitoring-plugins-connections
        - monitoring-plugins-contentage
        - monitoring-plugins-cpu_stats
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
        - monitoring-plugins-eth
        - monitoring-plugins-extras
        - monitoring-plugins-fail2ban
        - monitoring-plugins-file_age
        - monitoring-plugins-flexlm
        - monitoring-plugins-fping
        - monitoring-plugins-gitlab
        - monitoring-plugins-haproxy
        - monitoring-plugins-hpasm
        - monitoring-plugins-hpjd
        - monitoring-plugins-http
        - monitoring-plugins-icmp
        - monitoring-plugins-ide_smart
        - monitoring-plugins-ifoperstatus
        - monitoring-plugins-ifstatus
        - monitoring-plugins-ipmi-sensor1
        - monitoring-plugins-ircd
        - monitoring-plugins-keepalived
        - monitoring-plugins-ldap
        - monitoring-plugins-load
        - monitoring-plugins-log
        - monitoring-plugins-logrotate
        - monitoring-plugins-mailq
        - monitoring-plugins-mailstat
        - monitoring-plugins-maintenance
        - monitoring-plugins-mem
        - monitoring-plugins-memcached
        - monitoring-plugins-mrtg
        - monitoring-plugins-mrtgtraf
        - monitoring-plugins-mysql
        - monitoring-plugins-mysql_health
        - monitoring-plugins-nagios
        - monitoring-plugins-nfsmounts
        - monitoring-plugins-nis
        - monitoring-plugins-nrpe
        - monitoring-plugins-nt
        - monitoring-plugins-ntp_peer
        - monitoring-plugins-ntp_time
        - monitoring-plugins-nwstat
        - monitoring-plugins-openvpn
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
        - monitoring-plugins-rsync
        - monitoring-plugins-rsyslog
        - monitoring-plugins-running_kernel
        - monitoring-plugins-sar-perf
        - monitoring-plugins-sensors
        - monitoring-plugins-sks_keyserver
        - monitoring-plugins-smtp
        - monitoring-plugins-snmp
        - monitoring-plugins-ssh
        - monitoring-plugins-ssl_validity
        - monitoring-plugins-swap
        - monitoring-plugins-systemd_service
        - monitoring-plugins-systemd_timer
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
        - nrpe
        - nsca
        - nsca-client
        - nsca-ng-server

{%- if grains['osfullname'] == 'Leap' %}
{#- remove stock "openSUSE-Leap-15.x-x" repositories duplicating the pillar.osfullname managed repo-oss #}
{%- for repository_file in salt['file.find']('/etc/zypp/repos.d', maxdepth=1, mindepth=1, name='*.repo', type='f') %}
{%- if 'openSUSE-Leap-' in repository_file %}
{{ repository_file }}:
  file.absent
{%- endif %}
{%- endfor %}
{%- endif %}
