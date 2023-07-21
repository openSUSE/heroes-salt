mirrorcache:
  proxy_url: https://mirrorcache-eu.opensuse.org

grains:
  city: nuremberg
  country: de
  hostusage:
    - mirrorcache-eu
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Productive server for MirrorCache in the EU
  documentation:
    - https://mirrorcache.org/
  responsible:
    - anikitin
  partners: []
  weburls:
    - https://mirrorcache-eu.opensuse.org/
roles:
  - mirrorcache-webui
