cluster: apollo.openSUSE
grains:
  site: prg2
  hostusage:
    - openSUSE GitHub Runner
    - K3S
  reboot_safe: yes
  description: GitHub Runner for openSUSE
  documentation: []
  responsible:
    - SchoolGuy
  weburls: []
roles:
  - github_runner

network:
  interfaces:
    os-ghr-os:
      address: 2a07:de40:b27e:1208::a3/64
