include:
  - prometheus.service.running

prometheus_rules_tree:
  file.recurse:
    - name: /etc/prometheus/rules
    - source: salt://files/prometheus/alerts
    - dir_mode: '0755'
    - file_mode: '0644'
    - watch_in:
        - service: prometheus-service-running-prometheus
