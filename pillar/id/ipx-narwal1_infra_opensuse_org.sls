grains:
  city: QSC-nuremberg
  country: de-qsc
  hostusage:
    - static.o.o
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: stonehat-bare

  aliases: []
  description: Provider of static content like CSS and Javascript for openSUSE Webservers
  documentation: []
  responsible:
    - cboltz
  partners:
    - narwal4.infra.opensuse.org
    - narwal5.infra.opensuse.org
    - narwal6.infra.opensuse.org
    - narwal7.infra.opensuse.org
  weburls:
    - https://html5test.opensuse.org
    - https://shop.opensuse.org
    - https://static.opensuse.org
    - https://studioexpress.opensuse.org
roles:
  - web_static
