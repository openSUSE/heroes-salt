include:
  - cluster.anna_elsa

grains:
  city: nuremberg
  country: de
  hostusage:
    - ns2.i.o.o
    - ntp3.i.o.o
    - proxy-nue2.o.o
    - relay.i.o.o
  reboot_safe: yes
  virt_cluster: atreju

  aliases:
    - proxy-nue2.infra.opensuse.org
  description: HAproxy and PgBouncer
  documentation: []
  responsible: []
  partners:
    - anna.infra.opensuse.org
  weburls:
    - https://elsa.opensuse.org
  configure_ntp: false
roles:
  - ha
  - proxy
  - proxy_slave
  - ntp
