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
    - mirrorcache-backstage
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: MirrorCache Background jobs
  documentation:
    - https://mirrorcache.org/
  responsible:
    - anikitin
  partners: []
  weburls:
    - https://mirrorcache.opensuse.org/
roles:
  - mirrorcache-backstage
