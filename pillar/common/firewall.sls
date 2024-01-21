firewalld:
  services:
    node_exporter:
      description: Prometheus Node Exporter
      ports:
        tcp:
          - 9100
