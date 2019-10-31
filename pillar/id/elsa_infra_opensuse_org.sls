grains:
  city: nuremberg
  country: de
  hostusage:
    - ns2.i.o.o
    - ntp3.i.o.o
    - proxy-nue2.o.o
    - relay.i.o.o
  roles:
    - ha
    - proxy
    - proxy_slave
    - ntp
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju
  subrole_ntp: ntp3

  aliases:
    - proxy-nue2.infra.opensuse.org
  description: HAproxy and PgBouncer
  documentation: []
  responsible: []
  partners:
    - anna.infra.opensuse.org
  weburls:
    - https://elsa.opensuse.org
