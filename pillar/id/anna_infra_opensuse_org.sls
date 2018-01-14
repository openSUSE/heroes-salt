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
  salt_cluster: opensuse
  virt_cluster: atreju
  subrole_ntp: ntp2
