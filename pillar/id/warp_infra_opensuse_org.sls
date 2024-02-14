grains:
  country: cz
  hostusage:
    - SUSE -> openSUSE jump host
  reboot_safe: yes
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
sshd_config:
  ListenAddress:
    - 2a07:de40:b27e:1101::a  # os-s-warp
    - 2a07:de40:b27f:202::1   # s-j-os-out
profile:
  monitoring:
    nrpe:
      server_address: 2a07:de40:b27e:1101::a
prometheus:
  pkg:
    component:
      node_exporter:
        environ:
          args:
            web.listen-address: '[2a07:de40:b27e:1101::a]:9100'
