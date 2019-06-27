profile:
  monitoring:
    checks:
      check_postgres_backends: "/usr/lib/nagios/plugins/check_postgres_backends --warning='-50' --critical='-10'"
      check_postgres_bloat: "/usr/lib/nagios/plugins/check_postgres_bloat --db=mb_opensuse2 --warning='3000 M' --critical='5000 M'"
      check_postgres_last_autovacuum: "/usr/lib/nagios/plugins/check_postgres_last_autovacuum --warning='7d' --critical='14d' --db=mb_opensuse2"
      check_postgres_locks: "/usr/lib/nagios/plugins/check_postgres_locks --warning='60' --critical='total=50:waiting=1:exclusive=20'"
      check_postgres_wal_files: "/usr/lib/nagios/plugins/check_postgres_wal_files --critical='120' --warning='100'"

zypper:
  packages:
    postgresql: {}
    postgresql-llvmjit: {}
    postgresql-contrib: {}
    postgresql-server: {}
    monitoring-plugins-postgres: {}

