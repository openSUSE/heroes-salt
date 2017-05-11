mysql:
  salt_user:
    grants:
      - 'all privileges'
    salt_user_name: 'salt'
    salt_user_password: 'someotherpass'
  server:
    mysqld:
      # bigger packet size needed for importing SQL dumps
      max_allowed_packet: 64M
    root_password: 'somepass'
