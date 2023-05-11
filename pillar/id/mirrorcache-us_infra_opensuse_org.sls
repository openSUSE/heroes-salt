include:
  - ssh_keys.groups.download_infra
  - secrets.mirrorcache

mirrorcache:
  proxy_url: https://mirrorcache-us.opensuse.org

grains:
  city: provo
  country: us
  hostusage:
    - mirrorcache-us
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: bryce

  aliases: []
  description: Productive server for MirrorCache in the US
  documentation:
    - https://mirrorcache.org/
  responsible:
    - anikitin
  partners: []
  weburls:
    - https://mirrorcache-us.opensuse.org/
roles:
  - mirrorcache-webui
