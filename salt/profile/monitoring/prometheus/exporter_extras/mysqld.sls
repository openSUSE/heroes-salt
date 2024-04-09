# mysqld-exporter reads .my.cnf from the home directory
/var/lib/prometheus/.my.cnf:
  file.managed:
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[client]'
        - user = prometheus_exporter
        - password = {{ salt['pillar.get']('profile:monitoring:prometheus:mysqld-exporter:secrets:mariadb') }}
    - mode: '0600'
    - group: prometheus
    - user: prometheus
