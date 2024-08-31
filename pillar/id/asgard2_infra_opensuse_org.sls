include:
  - secrets.include_id

cluster: asgard
grains:
  site: prg2
  hostusage:
    - Firewall
    - Router
  reboot_safe: no
  description: Core firewall for openSUSE networks in PRG2
  documentation: []
  responsible:
    - crameleon
  weburls: []
  partners:
    - asgard1.infra.opensuse.org
roles:
  - gateway
  - ha
  - tayga
  - vpn.site_to_site
bird:
  server:
    router_id: 0.0.1.2
network:
  interfaces:
    os-asgard:
      addresses:
        - fd4b:5292:d67e:1000::2/64
        - 172.16.128.2/30
    os-p2p-pub:
      addresses:
        - 195.135.223.45/29
        - 2a07:de40:b27f:201::12/64
sshd_config:
  ListenAddress:
    - 2a07:de40:b27e:1100::2
    - 2a07:de40:b27e:1101::2
    - fd4b:5292:d67e:2::1
    - fd4b:5292:d67e:4::1
    - fd4b:5292:d67e:1000::2
profile:
  buddycheck:
    buddy: 2a07:de40:b27e:1203::1
prometheus:
  extra_files:
    ping_exporter:
      config:
        targets:
          # provo-gate p2p
          - 172.16.202.4
          - fd4b:5292:d67e:4::2
          # stonehat p2p
          - 172.16.202.6
          - 'fd4b:5292:d67e:6::'
