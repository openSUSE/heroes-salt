include:
  - cluster.asgard

grains:
  city: prague
  country: cz
  hostusage:
    - Firewall
    - Router
  reboot_safe: no
  virt_cluster: orbit
  description: Core firewall for openSUSE networks in PRG2
  documentation: []
  responsible: []
  weburls: []
  partners:
    - asgard1.infra.opensuse.org
roles:
  - gateway
  - ha
  - tayga
network:
  interfaces:
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
