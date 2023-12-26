include:
  - cluster.asgard

grains:
  city: prague
  country: cz
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
    - asgard2.infra.opensuse.org
roles:
  - gateway
  - ha
  - tayga
network:
  interfaces:
    os-p2p-pub:
      addresses:
        - 195.135.223.44/29
        - 2a07:de40:b27f:201::11/64
sshd_config:
  ListenAddress:
    - 2a07:de40:b27e:1100::1
    - 2a07:de40:b27e:1101::1
    - fd4b:5292:d67e:1::1
    - fd4b:5292:d67e:3::1
    - fd4b:5292:d67e:1000::1
profile:
  monitoring:
    nrpe:
      server_address: 2a07:de40:b27e:1203::1
