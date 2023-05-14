grains:
  city: provo
  country: us
  hostusage:
    - login3.o.o
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: bryce

  aliases: []
  description: Login proxy for servers with authentication
  documentation:
  responsible:
    - lrupp
  partners: []
  weburls:
    - https://login3.opensuse.org
roles:
  - login
  - login_master
