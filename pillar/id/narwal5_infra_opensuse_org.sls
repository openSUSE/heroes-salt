grains:
  city: nuremberg
  country: de
  hostusage:
    - static.o.o
    - static.o.o master
  roles:
    - static_master
    - web_static
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Provider of static content like CSS and Javascript for openSUSE Webservers (master)
  documentation: []
  responsible:
    - cboltz
  partners:
    - narwal6.infra.opensuse.org
    - narwal7.infra.opensuse.org
  weburls:
    - https://fontinfo.opensuse.org
    - https://html5test.opensuse.org
    - https://shop.opensuse.org
    - https://static.opensuse.org
    - https://studioexpress.opensuse.org
