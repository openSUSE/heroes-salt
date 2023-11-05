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
