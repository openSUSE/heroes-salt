include:
  ssh_keys.groups.download_infra

grains:
  city: nuremberg
  country: de
  hostusage:
    - mb devel
  roles: []
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Development server for MirrorCache
  documentation:
    - https://mirrorbrain.org/
  responsible:
    - anikitin
  partners: []
