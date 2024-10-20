cluster: hel
grains:
  site: prg2
  hostusage:
    - Int. Proxy
    - Int. DNS
  reboot_safe: yes
  aliases: []
  description: Internal reverse proxy/relay for various protocols and recursive resolver
  documentation: []
  responsible: []
  partners:
    - hel2.infra.opensuse.org
  weburls: []
roles:
  - ha
  - nameserver.recursor
  - ntp
  - proxy
  - pgbouncer

profile:
  buddycheck:
    buddy: hel2
  dns:
    powerdns:
      recursor:
        config:
          local_address:
            - 2a07:de40:b27e:1203::11
          webserver_address: 2a07:de40:b27e:1203::11
