grains:
  city: prague
  country: cz
  hostusage:
    - static.o.o
    - static.o.o master
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: falkor

  aliases: []
  description: Provider of static content like CSS and Javascript for openSUSE Webservers (master)
  documentation: []
  responsible:
    - cboltz
  partners:
    - narwal4.infra.opensuse.org
    - narwal6.infra.opensuse.org
    - narwal7.infra.opensuse.org
    - narwal8.infra.opensuse.org
  weburls:
    - https://fontinfo.opensuse.org
    - https://html5test.opensuse.org
    - https://people.opensuse.org
    - https://shop.opensuse.org
    - https://static.opensuse.org
    - https://studioexpress.opensuse.org
roles:
  - static_master
  - web_static
