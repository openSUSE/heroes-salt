grains:
  city: provo
  country: us
  hostusage:
    - postgreSQL
  reboot_safe: yes

  aliases:
    - nala.infra.opensuse.org
    - provo-mirrordb3.infra.opensuse.org
    - mirrordb3-nossl-v6
    - mirrordb3-nossl-v4
    - mirrordb3-ssl-v4 
    - mirrordb3-ssl-v6
  description: postgreSQL server in Provo. As failover for download.o.o
  documentation: 
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Provo-mirroropensuseorg
  responsible:
    - lrupp
  partners: []
  weburls: []
roles:
  - postgresql
