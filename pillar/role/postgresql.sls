profile:
  monitoring:
    checks:
      check_postgres_backends: "/usr/lib/nagios/plugins/check_postgres_backends --warning='-50' --critical='-10'"
      check_postgres_locks: "/usr/lib/nagios/plugins/check_postgres_locks --warning='60' --critical='total=50:waiting=1:exclusive=20'"
      check_postgres_wal_files: "/usr/lib/nagios/plugins/check_postgres_wal_files --critical='120' --warning='100'"

    {% set osrelease = salt['grains.get']('osrelease') %}
    {% if osrelease == '15.0' %}
    check_zypper:
      whitelist:
        # packages from server:database:postgresql
        - libpq5
        - postgresql
        - postgresql-contrib
        - postgresql-llvmjit
        - postgresql-server
        - postgresql11
        - postgresql11-contrib
        - postgresql11-ip4r
        - postgresql11-llvmjit
        - postgresql11-repmgr
        - postgresql11-server
        - repmgr
    {% endif %}

zypper:
  packages:
    postgresql: {}
    postgresql-llvmjit: {}
    postgresql-contrib: {}
    postgresql-server: {}
    monitoring-plugins-postgres: {}
  repositories:
    server_database_postgresql:
      baseurl: http://download.infra.opensuse.org/repositories/server:/database:/postgresql/$releasever/
      priority: 99
      refresh: True
