include:
  - .

backupscript:
  postgresql:
    backupdir: /backup/postgresql
    compress_opts: -T6
    email: root@localhost
    retention: 21
