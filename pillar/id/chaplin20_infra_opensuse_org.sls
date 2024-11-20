cluster: chaplin
grains:
  site: slc1
  hostusage:
    - Hypervisor
  reboot_safe: no
  description: Hypervisor for virtual machines related to automation and management
  documentation: []
  responsible: []
  weburls: []
  partners:
    - chaplin21.infra.opensuse.org
roles:
  - hypervisor.standalone
network:
  interfaces:
    os-bare:
      address: 2a07:de40:617e:1800::20/64
