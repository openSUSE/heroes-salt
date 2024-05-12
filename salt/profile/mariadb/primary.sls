mariadb_scripts:
  file.managed:
    - names:
        - /usr/local/sbin/backup_replica_sync.sh:
            - source: salt://{{ slspath }}/files/usr/local/sbin/backup_replica_sync.sh
    - template: jinja
    - mode: '0750'
    - group: wheel
