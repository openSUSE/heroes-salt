include:
  - cluster.hel

grains:
  city: prague
  country: cz
  hostusage:
    - Internal Proxy
  reboot_safe: yes
  virt_cluster: falkor
  aliases: []
  description: Internal reverse proxy/relay for various protocols
  documentation: []
  responsible: []
  partners:
    - hel2.infra.opensuse.org
  weburls: []
roles:
  - ha
  - ntp
  - proxy
  - pgbouncer
