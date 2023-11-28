include:
  - cluster.atlas

grains:
  city: prague
  country: cz
  hostusage:
    - Proxy
  reboot_safe: yes
  virt_cluster: falkor
  aliases: []
  description: Public facing reverse proxy/relay for various protocols
  documentation: []
  responsible: []
  partners:
    - atlas1.infra.opensuse.org
  weburls: []
roles:
  - ha
  - proxy
network:
  interfaces:
    os-public:
      addresses:
        - 2a07:de40:b27e:1204::9/64   # login
        - 2a07:de40:b27e:1204::52/64  # mx2.o.o
        - 172.16.130.52/24
  routes:
    default4:
      options:
        - src 172.16.130.12
    default6:
      options:
        - src 2a07:de40:b27e:1204::12
