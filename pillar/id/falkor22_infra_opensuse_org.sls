include:
  - cluster.falkor

grains:
  city: prague
  country: cz
  hostusage: []
  reboot_safe: no
  virt_cluster: falkor-bare
  description: Hypervisor
  documentation: []
  responsible: []
  weburls: []
roles:
  - hypervisor.cluster
network:
  interfaces:
    os-bare:
      address: 2a07:de40:b27e:1201::f2/64
    os-f-cluster:
      address: fd4b:5292:d67e:1002::f2/64
    os-f-nfs:
      address: 192.168.202.22/24
suse_ha:
  cluster:
    nodeid: 3
  multicast:
    bind_address: fd4b:5292:d67e:1002::f2
