mariadb_scripts:
  file.managed:
    - names:
        - /usr/local/sbin/backup_replica_restore.sh:
            - source: salt://{{ slspath }}/files/usr/local/sbin/backup_replica_restore.sh
    - template: jinja
    - mode: '0750'
    - group: wheel
