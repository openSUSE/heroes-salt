cluster: tyr
grains:
  site: slc1
  hostusage:
    - Int. Proxy
    - Int. DNS
  reboot_safe: yes
  aliases: []
  description: Internal reverse proxy/relay for various protocols and recursive resolver
  documentation: []
  responsible: []
  partners:
    - tyr1.infra.opensuse.org
  weburls: []
roles:
  - ha
  - nameserver.recursor
  - ntp
  - proxy

profile:
  buddycheck:
    buddy: tyr1
  dns:
    powerdns:
      recursor:
        config:
          local_address:
            - 2a07:de40:617e:1903::12
          webserver_address: 2a07:de40:617e:1903::12
