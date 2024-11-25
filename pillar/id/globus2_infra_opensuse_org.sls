cluster: globus
grains:
  site: slc1
  hostusage:
    - Proxy
  reboot_safe: yes
  aliases: []
  description: Public facing reverse proxy/relay for various protocols
  documentation: []
  responsible: []
  partners:
    - globus1.infra.opensuse.org
  weburls: []
roles:
  - ha
  - proxy
network:
  routes:
    default4:
      options:
        - src 172.16.113.12
    default6:
      options:
        - src 2a07:de40:617e:1904::12
profile:
  buddycheck:
    buddy: globus1
