include:
  - ssh_keys.groups.download_infra
  - secrets.mirrorcache

mirrorcache:
  root: /mnt
  backstage_workers: 12

grains:
  city: nuremberg
  country: de
  hostusage:
    - mirrorcache-stats
  reboot_safe: yes
  salt_cluster: opensuse
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
