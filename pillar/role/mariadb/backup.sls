include:
  - .
  - role.common.authorized-exec

backupscript:
  mysql:
    backupdir: /backup
    compress_after_unlock: false
    create_backupdir: false
    mysql_script_before_dump: /usr/share/doc/packages/mysql-backupscript/mysql_scripts_before_dump.sh
    retention: 60

sshd_config:
  PermitRootLogin: prohibit-password

{%- set mysqlrootkey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9gkF+79Z/e6yFuaquCKpokKIwZHc4Ac09WTxUjNOGw' %}
users:
  root:
    ssh_auth_file:
      - command="/usr/bin/authorized-exec /etc/authorized-exec/mysql",from="galera1.infra.opensuse.org",restrict {{ mysqlrootkey }} root@galera1

profile:
  authorized-exec:
    mysql:
      root:
        pubkey: {{ mysqlrootkey }}
        commands:
          - 'true'
          - 'test -d /backup/bootstrap/'
          - 'mountpoint -q /backup'
          - 'mkdir /backup/bootstrap/'
          - 'stat -fc%a /backup/bootstrap/'
          - 'rsync --server -v?log[a-zA-Z\.]* \. /backup/bootstrap/[0-9]{8}'  # there is some random nonsense in the form of e.iLsfxCIvu in the middle
          - '/usr/local/sbin/backup_replica_restore\.sh -f galera[1-3]\.infra.opensuse\.org -d /backup/bootstrap/[0-9]{8} -l mysql-bin\.[0-9]{6} -p [0-9]+'
          - 'mariadb -e show slave STATUS\G; | grep Running | grep -v Slave_SQL_Running_State'
