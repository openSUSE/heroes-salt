cluster: apollo.cobbler
grains:
  site: prg2
  hostusage:
    - GitHub Runner
    - K3S
  reboot_safe: yes
  description: GitHub Runner for Cobbler
  documentation: []
  responsible:
    - SchoolGuy
  weburls: []
roles:
  - github_runner

network:
  interfaces:
    os-ghr-c:
      address: 2a07:de40:b27e:1207::a/128
