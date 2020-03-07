{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.mysql_tmp
{% endif %}

mysql:
  server:
    mysqld:
      # bigger packet size needed for importing SQL dumps
      max_allowed_packet: 64M
    # root_password included from pillar/secrets/role/mysql_tmp.sls
    lookup:
      python: python3-PyMySQL

  # database and user for forums migration
  database:
    - forums
  user:
    forums:
      # password included from pillar/secrets/role/mysql_tmp.sls
      host: '%'
      databases:
        - database: forums
          grants: ['all privileges']

