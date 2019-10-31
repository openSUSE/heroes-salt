grains:
  city: nuremberg
  country: de
  hostusage:
    - ns1.i.o.o
    - ntp2.i.o.o
    - proxy-nue1.o.o
    - relay.i.o.o
  roles:
    - ha
    - proxy
    - proxy_master
    - ntp
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju
  subrole_ntp: ntp2

  aliases:
    - proxy-nue1.infra.opensuse.org
  description: HAproxy and PgBouncer
  documentation: []
  responsible: []
  partners:
    - elsa.infra.opensuse.org
  weburls:
    - https://anna.opensuse.org
