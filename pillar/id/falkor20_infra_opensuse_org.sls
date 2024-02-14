cluster: falkor
grains:
  country: cz
  hostusage:
    - Hypervisor
  reboot_safe: no
  description: Hypervisor
  documentation: []
  responsible: []
  weburls: []
roles:
  - hypervisor.cluster
network:
  interfaces:
    os-bare:
      address: 2a07:de40:b27e:1201::f0/64
    os-f-cluster:
      address: fd4b:5292:d67e:1002::f0/64
    os-f-nfs:
      address: 192.168.202.20/24
suse_ha:
  cluster:
    nodeid: 1
  multicast:
    bind_address: fd4b:5292:d67e:1002::f0
profile:
  monitoring:
    nrpe:
      server_address: 2a07:de40:b27e:1201::f0
prometheus:
  pkg:
    component:
      node_exporter:
        environ:
          args:
            web.listen-address: '[2a07:de40:b27e:1201::f0]:9100'
