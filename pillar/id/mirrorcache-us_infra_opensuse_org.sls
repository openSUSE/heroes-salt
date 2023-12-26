mirrorcache:
  proxy_url: https://mirrorcache-us.opensuse.org

grains:
  country: us
  hostusage:
    - mirrorcache-us
  reboot_safe: yes

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
