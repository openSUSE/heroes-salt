mysql:
  server:
    root_password: 'somepass'
    mysqld:
      # bigger packet size needed for importing SQL dumps
      max_allowed_packet: 64M
  salt_user:
    salt_user_name: 'salt'
    salt_user_password: 'someotherpass'
    grants:
      - 'all privileges'
