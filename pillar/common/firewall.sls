firewalld:
  enabled: false
  FlushAllOnReload: 'yes'
  purge_zones: true
  services:
    node_exporter:
      description: Prometheus Node Exporter
      ports:
        tcp:
          - 9100
  zones:
    drop:
      target: DROP
    internal:
      services:
        - node_exporter
        - ssh
