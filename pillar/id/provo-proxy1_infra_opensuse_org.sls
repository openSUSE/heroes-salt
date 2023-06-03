grains:
  city: provo
  country: us
  hostusage:
    - proxy
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: bryce

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
