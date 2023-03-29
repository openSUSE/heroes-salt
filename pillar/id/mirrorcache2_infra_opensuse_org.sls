include:
  - ssh_keys.groups.download_infra
  - secrets.mirrorcache

mirrorcache:
  proxy_url: https://mirrorcache-eu.opensuse.org

grains:
  city: nuremberg
  country: de
  hostusage:
<<<<<<< HEAD
    - mirrorcache
=======
    - mirrorcache2
  roles:
    - mirrorcache-webui
>>>>>>> f23fa68 (Adjust MirrorCache states, add container tests)
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
roles: []
