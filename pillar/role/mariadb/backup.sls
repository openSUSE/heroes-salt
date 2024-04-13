include:
  - .

backupscript:
  mysql:
    backupdir: /backup
    compress_after_unlock: false
    create_backupdir: false
    mysql_script_before_dump: /usr/share/doc/packages/mysql-backupscript/mysql_scripts_before_dump.sh
    retention: 60
