{%- set host = grains['host'] %}

os-update:
  ignore_services_from_restart:
    - postgresql

nfs:
  mount:
    {{ host }}:
      location: backup:/
      mountpoint: /backup
      opts:
        - _netdev
        - defaults
        - nofail

profile:
  monitoring:
    checks:
      check_postgres_backends: "/usr/lib/nagios/plugins/check_postgres_backends --warning='-50' --critical='-10'"
      check_postgres_locks: "/usr/lib/nagios/plugins/check_postgres_locks --warning='60' --critical='total=50:waiting=1:exclusive=20'"
      check_postgres_wal_files: "/usr/lib/nagios/plugins/check_postgres_wal_files --critical='120' --warning='100'"

zypper:
  packages:
    postgresql: {}
    postgresql-llvmjit: {}
    postgresql-contrib: {}
    postgresql-server: {}
    monitoring-plugins-postgres: {}
  repositories:
    server_database_postgresql:
      baseurl: https://downloadcontent.opensuse.org/repositories/server:/database:/postgresql/$releasever/
      priority: 99
      refresh: True
