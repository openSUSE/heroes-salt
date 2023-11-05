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
    - hel1.infra.opensuse.org
  weburls: []
roles:
  - ha
  - proxy
  - pgbouncer
