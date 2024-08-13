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
    - chaplin20.infra.opensuse.org
roles:
  - hypervisor.standalone
