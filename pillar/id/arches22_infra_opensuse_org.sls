cluster: arches
grains:
  site: slc1
  hostusage:
    - Hypervisor
  reboot_safe: no
  description: Hypervisor
  documentation: []
  responsible: []
  weburls: []
  partners:
    - arches20.infra.opensuse.org
    - arches21.infra.opensuse.org
roles:
  - hypervisor.cluster
