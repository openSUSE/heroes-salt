firewalld:
  enabled: false
  FlushAllOnReload: 'yes'
  services:
    node_exporter:
      description: Prometheus Node Exporter
      ports:
        tcp:
          - 9100
  zones:
    internal:
      services:
        - node_exporter
        - ssh
