cluster: atlas
grains:
  site: prg2
  hostusage:
    - Proxy
  reboot_safe: yes
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
        - 2a07:de40:b27e:1204::8/64   # atlas-login1.i.o.o
        - 2a07:de40:b27e:1204::51/64  # mx1.o.o
        - 172.16.130.51/24
  routes:
    default4:
      options:
        - src 172.16.130.11
    default6:
      options:
        - src 2a07:de40:b27e:1204::11
