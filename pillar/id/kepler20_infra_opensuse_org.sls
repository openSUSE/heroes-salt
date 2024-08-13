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
    - kepler21.infra.opensuse.org
roles:
  - hypervisor.standalone
