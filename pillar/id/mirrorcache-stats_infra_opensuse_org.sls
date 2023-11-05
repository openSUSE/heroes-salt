mirrorcache:
  root: /mnt
  backstage_workers: 12

grains:
  city: nuremberg
  country: de
  hostusage:
    - mirrorcache-stats
  reboot_safe: yes
  virt_cluster: atreju

  aliases: []
  description: Database server and backstage workers for MirrorCache
  documentation:
    - https://mirrorcache.org/
  responsible:
    - anikitin
  partners: []
roles:
  - mirrorcache-db-server
  - mirrorcache-backstage
