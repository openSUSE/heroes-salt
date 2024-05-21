include:
  - .listen
  - .node_exporter
  {%- if grains['virtual'] == 'physical' %}
  - .smartctl_exporter
  {%- endif %}

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
