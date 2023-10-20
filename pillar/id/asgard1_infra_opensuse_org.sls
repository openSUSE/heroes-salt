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
    - asgard2.infra.opensuse.org
roles:
  - gateway
  - ha
