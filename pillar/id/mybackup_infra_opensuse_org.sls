grains:
  site: prg2
  hostusage:
    - MySQL backup
  reboot_safe: yes

  aliases: []
  description: Backup server for the Galera Cluster
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Galera_Cluster
  responsible:
    - crameleon
  partners:
    - galera1.infra.opensuse.org
    - galera2.infra.opensuse.org
    - galera3.infra.opensuse.org
  weburls: []
roles:
  - mariadb.backup
