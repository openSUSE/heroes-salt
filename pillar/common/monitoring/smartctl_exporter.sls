prometheus:
  pkg:
    component:
      smartctl_exporter:
        name: prometheus-smartctl_exporter
        service:
          name: prometheus-smartctl_exporter
          reload: false
        environ:
          args:
            log.level: debug
            smartctl.interval: 10m
  wanted:
    component:
      - smartctl_exporter
