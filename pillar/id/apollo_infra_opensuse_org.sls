cluster: apollo.cobbler
grains:
  site: prg2
  hostusage:
    - Cobbler GitHub Runner
    - K3S
  reboot_safe: yes
  description: GitHub Runner for Cobbler
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Apolloinfraopensuseorg
  responsible:
    - SchoolGuy
  weburls: []
roles:
  - github_runner

network:
  interfaces:
    os-ghr-c:
      address: 2a07:de40:b27e:1207::a/64
