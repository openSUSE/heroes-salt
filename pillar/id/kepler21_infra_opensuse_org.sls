cluster: kepler
grains:
  site: slc1
  hostusage:
    - Hypervisor
  reboot_safe: no
  description: Hypervisor for virtual machines related to networking
  documentation: []
  responsible: []
  weburls: []
  partners:
    - kepler20.infra.opensuse.org
roles:
  - hypervisor.standalone
network:
  interfaces:
    os-bare:
      address: 2a07:de40:617e:1800::11/64
