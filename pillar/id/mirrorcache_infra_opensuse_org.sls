include:
  - ssh_keys.groups.download_infra
  - secrets.mirrorcache

mirrorcache:
  proxy_url: https://mirrorcache.opensuse.org

grains:
  city: nuremberg
  country: de
  hostusage:
    - mirrorcache
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Development server for MirrorCache
  documentation:
    - https://mirrorcache.org/
  responsible:
    - anikitin
  partners: []
  weburls:
    - https://mirrorcache.opensuse.org/
roles:
  - mirrorcache-webui
