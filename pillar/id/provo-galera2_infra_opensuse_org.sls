grains:
  site: prv1
  hostusage:
    - Galera node (MySQL)
  reboot_safe: no

  aliases:
    - galera5.infra.opensuse.org
  description: Node for the MySQL cluster in Provo based on Galera
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Galera_Cluster
  responsible:
    - lrupp
  partners:
    - galera1.infra.opensuse.org
    - galera2.infra.opensuse.org
    - galera3.infra.opensuse-org
    - provo-galera1.infra.opensuse.org
    - provo-galera3.infra.opensuse-org
  weburls: []
roles:
  - mariadb
