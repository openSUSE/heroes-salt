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
  reboot_safe: unknown
  salt_cluster: opensuse
  virt_cluster: atreju
  subrole_ntp: ntp3
