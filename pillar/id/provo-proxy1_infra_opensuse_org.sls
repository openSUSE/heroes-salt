include:
  - cluster.mufasa

grains:
  country: us
  hostusage:
    - proxy
  reboot_safe: yes

  aliases:
    - mufasa.infra.opensuse.org
  description: HAproxy and PgBouncer in Provo. Currently not HA.
  documentation: []
  responsible: []
  partners: []
  weburls:
    - https://proxy-prv1.opensuse.org
roles:
  - proxy
