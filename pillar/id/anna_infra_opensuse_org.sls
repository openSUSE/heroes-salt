include:
  - cluster.anna_elsa

grains:
  city: nuremberg
  country: de
  hostusage:
    - ns1.i.o.o
    - ntp2.i.o.o
    - proxy-nue1.o.o
    - relay.i.o.o
  reboot_safe: yes
  virt_cluster: atreju

  aliases:
    - proxy-nue1.infra.opensuse.org
  description: HAproxy and PgBouncer
  documentation: []
  responsible: []
  partners:
    - elsa.infra.opensuse.org
  weburls:
    - https://anna.opensuse.org
  configure_ntp: false
roles:
  - ha
  - proxy
  - proxy_master
  - ntp
