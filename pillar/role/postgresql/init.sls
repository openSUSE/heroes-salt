include:
  - role.common.backup

os-update:
  ignore_services_from_restart:
    - postgresql

profile:
  monitoring:
    checks:
      check_postgres_backends: "/usr/lib/nagios/plugins/check_postgres_backends --warning='-50' --critical='-10'"
      check_postgres_locks: "/usr/lib/nagios/plugins/check_postgres_locks --warning='60' --critical='total=50:waiting=1:exclusive=20'"
      check_postgres_wal_files: "/usr/lib/nagios/plugins/check_postgres_wal_files --critical='120' --warning='100'"

prometheus:
  wanted:
    component:
      - postgres_exporter
  pkg:
    component:
      postgres_exporter:
        environ:
          extra:
            DATA_SOURCE_NAME: >-
              host=/run/postgresql
              user=postgres

sysctl:
  params:
    ## https://www.postgresql.org/docs/current/static/kernel-resources.html
    # Members of group my-hugetlbfs(2021) can allocate "huge" Shared memory segment
    vm.hugetlb_shm_group: 1000
    # echo $(grep ^VmPeak /proc/$(head -n 1 /var/lib/pgsql/data/postmaster.pid)/status | awk '" " { print $2 }')/2048 | bc
    vm.nr_hugepages: 6415
    vm.overcommit_memory: 2

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
