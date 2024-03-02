prometheus:
  extra_files:
    ping_exporter:
      component: ping_exporter
  pkg:
    component:
      ping_exporter:
        name: prometheus-ping_exporter
        service:
          name: prometheus-ping_exporter
          reload: false
  wanted:
    component:
      - ping_exporter
