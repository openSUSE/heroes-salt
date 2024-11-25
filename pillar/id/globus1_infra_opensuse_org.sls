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
    - globus2.infra.opensuse.org
  weburls: []
roles:
  - ha
  - proxy
network:
  routes:
    default4:
      options:
        - src 172.16.113.11
    default6:
      options:
        - src 2a07:de40:617e:1904::11
profile:
  buddycheck:
    buddy: globus2
