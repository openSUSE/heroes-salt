grains:
  city: prague
  country: cz
  hostusage:
    - en.o.o (all *.o.o wikis)
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: falkor

  aliases:
    - wiki.infra.opensuse.org
  description: $lang.opensuse.org wiki pages
  documentation: []
  responsible:
    - cboltz
  partners: []
  weburls:
    - https://en.opensuse.org
    - https://de.opensuse.org
    # instead of the full list... ;-)
    - https://$lang.opensuse.org
    - https://languages.opensuse.org
    - https://files.opensuse.org
roles:
  - wiki
