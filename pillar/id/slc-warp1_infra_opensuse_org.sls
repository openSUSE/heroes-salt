grains:
  site: slc1
  hostusage:
    - SUSE -> openSUSE jump host
  reboot_safe: yes
  aliases: []
  description: SSH bastion serving as an entrypoint to openSUSE from SUSE networks
  documentation: []
  responsible:
    - crameleon
    - enginfra@suse
  partners: []
  weburls: []
roles: []
network:
  routes:
    2a07:de40:619f:2::/64:
      gateway: 2a07:de40:61bf:2:ffff:ffff:ffff:ffff
sshd_config:
  ListenAddress:
    - 2a07:de40:617e:1803::a  # os-s-warp
    - 2a07:de40:619f:2::1     # s-j-os-out
