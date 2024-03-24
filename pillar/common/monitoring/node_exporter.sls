prometheus:
  wanted:
    component:
      - node_exporter

  pkg:
    component:
      node_exporter:
        environ:
          args:
            collector.filesystem.fs-types-exclude: "'^(\
                tmpfs\
                |cgroup2?\
                |debugfs\
                |devpts\
                |devtmpfs\
                |fusectl\
                |overlay\
                |proc\
                |procfs\
                |pstore\
              )$'"
            collector.netdev.device-exclude: "'^d-o?s-[a-z]+$'"
            collector.zfs: false
            collector.textfile.directory: /var/spool/prometheus
            collector.thermal_zone: false
            collector.powersupplyclass: false
