include:
  ssh_keys.groups.download_infra

grains:
  city: nuremberg
  country: de
  hostusage:
    - mirrorcache
  roles: []
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Productive server for MirrorCache in the EU
  documentation:
    - https://mirrorbrain.org/
  responsible:
    - anikitin
  partners: []
  weburls:
    - https://mirrorcache-eu.opensuse.org/
