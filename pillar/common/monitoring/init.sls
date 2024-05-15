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
          cluster: cluster
          roles: role

users:
  monitor:
    fullname: Moni Toring
    createhome: false
    system: true
