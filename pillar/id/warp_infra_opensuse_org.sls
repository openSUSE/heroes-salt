grains:
  city: prague
  country: cz
  hostusage:
    - SUSE -> openSUSE jump host
  reboot_safe: yes
  virt_cluster: squanchy
  aliases: []
  description: SSH bastion serving as an entrypoint to openSUSE from SUSE networks
  documentation: []
  responsible: []
  partners: []
  weburls: []
roles: []
network:
  routes:
    2a07:de40:b280:25::/64:
      gateway: 2a07:de40:b27f:202:ffff:ffff:ffff:ffff
