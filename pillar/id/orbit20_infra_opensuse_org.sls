grains:
  country: cz
  hostusage:
    - Hypervisor
  reboot_safe: no
  description: Hypervisor for virtual machines related to networking
  documentation: []
  responsible: []
  weburls: []
  partners:
    - orbit21.infra.opensuse.org
roles:
  - hypervisor.standalone

network:
  interfaces:
    os-bare:
      address: 2a07:de40:b27e:1201::a0/64
profile:
  monitoring:
    nrpe:
      server_address: 2a07:de40:b27e:1201::a0
prometheus:
  pkg:
    component:
      node_exporter:
        environ:
          args:
            web.listen-address: '[2a07:de40:b27e:1201::a0]:9100'
