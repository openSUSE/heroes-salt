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
