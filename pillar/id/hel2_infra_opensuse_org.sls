include:
  - cluster.hel

grains:
  city: prague
  country: cz
  hostusage:
    - Int. Proxy
    - Int. DNS
  reboot_safe: yes
  virt_cluster: falkor
  aliases: []
  description: Internal reverse proxy/relay for various protocols and recursive resolver
  documentation: []
  responsible: []
  partners:
    - hel1.infra.opensuse.org
  weburls: []
roles:
  - ha
  - nameserver.recursor
  - ntp
  - proxy
  - pgbouncer

profile:
  dns:
    powerdns:
      recursor:
        config:
          local_address:
            - 2a07:de40:b27e:1203::12
          webserver_address: 2a07:de40:b27e:1203::12
