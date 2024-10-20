mirrorcache:
  backstage_workers: 12

grains:
  site: prv1
  hostusage:
    - mirrorcache-us-db
  reboot_safe: yes

  aliases: []
  description: Productive DB for MirrorCache in the US
  documentation:
    - https://mirrorcache.org/
  responsible:
    - anikitin
  partners: []
roles:
  - mirrorcache-db-server
  - mirrorcache-backstage
