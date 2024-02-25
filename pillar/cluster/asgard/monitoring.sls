include:
  - common.monitoring.ping_exporter

prometheus:
  extra_files:
    ping_exporter:
      config:
        ping:
          interval: 10s
          timeout: 2s
          history-size: 100
