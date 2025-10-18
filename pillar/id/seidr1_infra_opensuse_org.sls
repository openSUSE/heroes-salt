grains:
  site: prg2
  hostusage:
    - Salt Master of Masters
  reboot_safe: yes
  aliases:
    - salt.infra.opensuse.org
  description: Salt Master of Masters
  documentation: []
  responsible:
    - crameleon
  partners:
    - volva1.infra.opensuse.org
    - volva2.infra.opensuse.org
    - witch1.infra.opensuse.org
    #- witch2.infra.opensuse.org
  weburls: []
roles:
  - salt.master
  - salt.masterofmasters
