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
    - atlas2.infra.opensuse.org
  weburls: []
roles:
  - ha
  - proxy
network:
  interfaces:
    os-public:
      addresses:
        - 2a07:de40:b27e:1204::51/64  # mx1.o.o
        - 172.16.130.51/24
