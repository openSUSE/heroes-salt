include:
  - role.common.backup

os-update:
  ignore_services_from_restart:
    - postgresql

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
  repositories:
    server_database_postgresql:
      baseurl: https://downloadcontent.opensuse.org/repositories/server:/database:/postgresql/$releasever/
      priority: 99
      refresh: True
