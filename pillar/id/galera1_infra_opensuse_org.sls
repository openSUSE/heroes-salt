grains:
  country: cz
  hostusage:
    - Galera node (MySQL)
  reboot_safe: no

  aliases: []
  description: Node of the MySQL cluster based on Galera
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Galera_Cluster
    - https://www.symmcom.com/docs/how-tos/databases/how-to-recover-mariadb-galera-cluster-after-partial-or-full-crash
  responsible:
    - crameleon
  partners:
    - galera2.infra.opensuse.org
    - galera3.infra.opensuse.org
    - provo-galera1.infra.opensuse.org
    - provo-galera2.infra.opensuse.org
    - provo-galera3.infra.opensuse-org
  weburls: []
roles:
  - mariadb
