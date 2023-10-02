mirrorcache:
  backstage_workers: 12

grains:
  city: provo
  country: us
  hostusage:
    - mirrorcache-us-db
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: bryce

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