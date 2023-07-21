mysql:
  server:
    mysqld:
      max_allowed_packet: 128M
      innodb_buffer_pool_size: 4G
      innodb_flush_log_at_trx_commit: 0
  database:
    - mirrorcache
  user:
    mirrorcache:
      databases:
        - database: mirrorcache
          grants: ['all']

