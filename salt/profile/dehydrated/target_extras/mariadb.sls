# for reload-ssl
/home/cert/.my.cnf:
  file.managed:
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[client]'
        - user = cert
        - password = {{ salt['pillar.get']('profile:dehydrated:target:secrets:mariadb') }}
    - mode: '0400'
    - group: root
    - user: root
