include:
  - .

backupscript:
  mysql:
    backupdir: /backup
    compress_after_unlock: false
    create_backupdir: false
    mysql_script_before_dump: /usr/share/doc/packages/mysql-backupscript/mysql_scripts_before_dump.sh
    retention: 60

users:
  root:
    ssh_auth_file:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9gkF+79Z/e6yFuaquCKpokKIwZHc4Ac09WTxUjNOGw root@galera1
