include:
  - .listen
  - .node_exporter

profile:
  monitoring:
    prometheus:
      salt_metrics:
        grains:
          reboot_safe: reboot_safe
          responsible: responsible
        pillar:
          roles: role
