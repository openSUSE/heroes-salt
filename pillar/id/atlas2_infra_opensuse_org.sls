include:
  - cluster.atlas

grains:
  city: prague
  country: cz
  hostusage:
    - Proxy
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: falkor
  aliases: []
  description: Public facing reverse proxy/relay for various protocols
  documentation: []
  responsible: []
  partners:
    - atlas1.infra.opensuse.org
  weburls: []
roles:
  - ha
