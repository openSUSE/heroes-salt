include:
  - secrets.include_id

cluster: avalon
grains:
  site: slc1
  hostusage:
    - Firewall
    - Router
  reboot_safe: no
  description: Core firewall for openSUSE networks in SLC1
  documentation: []
  responsible:
    - crameleon
  weburls: []
  partners:
    - avalon2.infra.opensuse.org
roles:
  - gateway
  - ha
  - tayga
  - vpn.site_to_site
bird:
  server:
    router_id: 0.0.2.2
network:
  interfaces:
    os-avalon:
      addresses:
        - fd03:7bbf:d626:1700::2/64
        - 172.16.112.2/30
    os-avalon-ct:
      addresses:
        - fd03:7bbf:d626:1701::2/64
    os-p2p-pub:
      addresses:
        - 195.135.220.45/29
        - 2a07:de40:617f:201::12/64
  routes:
    default6:
      options:
        - src 2a07:de40:617f:201::12
sshd_config:
  ListenAddress:
    - fd03:7bbf:d626:1700::2
    - fda1:21af:580f:1::2
    - 2a07:de40:617e:1802::2
    - 2a07:de40:617e:1803::2
profile:
  buddycheck:
    buddy: fd03:7bbf:d626:1700::1
prometheus:
  pkg:
    component:
      node_exporter:
        environ:
          args:
            web.listen-address: '[fd03:7bbf:d626:1700::2]:9100'
