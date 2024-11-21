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
network:
  interfaces:
    os-a-cluster:
      address: fda1:21af:580f:1703::a2/64
    os-a-nfs:
      address: fdb5:ae73:9cbd:1706::a2/64
    os-bare:
      address: 2a07:de40:617e:1800::a2/64
suse_ha:
  cluster:
    nodeid: 3
  multicast:
    bind_address: fda1:21af:580f:1703::a2
