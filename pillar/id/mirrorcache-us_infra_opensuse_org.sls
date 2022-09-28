include:
  ssh_keys.groups.download_infra

grains:
  city: provo
  country: us
  hostusage:
    - mirrorcache
  roles: []
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: bryce

  aliases: []
  description: Productive server for MirrorCache in the US
  documentation:
    - https://mirrorbrain.org/
  responsible:
    - anikitin
  partners: []
  weburls:
    - https://mirrorcache-us.opensuse.org/
