include:
  - cluster.asgard

grains:
  city: prague
  country: cz
  hostusage:
    - Firewall
    - Router
  reboot_safe: no
  salt_cluster: opensuse
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
network:
  interfaces:
    os-p2p-pub:
      addresses:
        - 195.135.223.45/29
        - 2a07:de40:b27f:201::12/64
