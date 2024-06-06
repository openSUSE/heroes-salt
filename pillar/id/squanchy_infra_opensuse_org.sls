cluster: squanchy
grains:
  country: cz
  hostusage:
    - Hypervisor
  reboot_safe: no
  description: Hypervisor for virtual machines related to automation and management
  documentation: []
  responsible: []
  weburls: []
roles:
  - hypervisor.standalone

network:
  interfaces:
    os-bare:
      address: 2a07:de40:b27e:1201::c/64
