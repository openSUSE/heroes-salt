include:
  - prometheus.service

/etc/prometheus/templates:
  file.recurse:
    - source: salt://profile/monitoring/prometheus/files/templates
    - watch_in:
        - prometheus-service-running-prometheus-alertmanager
