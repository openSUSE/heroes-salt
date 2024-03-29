/etc/opt/promact/config.yaml:
  file.managed:
    - source: salt://{{ slspath }}/files/promact/config.yaml.jinja
    - template: jinja

/etc/opt/promact/my.cnf:
  file.managed:
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[mariadb-admin]'
        - user = monitor
        - password = {{ salt['pillar.get']('profile:monitoring:prometheus:promact:secrets:mariadb') }}
    - mode: '0640'
    - group: promact

/srv/www/monitor-internal/promact-out:
  file.directory:
    - makedirs: true
    - user: promact

/usr/local/libexec/promact:
  file.recurse:
    - source: salt://{{ slspath }}/files/promact/scripts
    - file_mode: '0755'
    - clean: true
    - template: jinja

/etc/systemd/system/promact.service.d/salt.conf:
  file.managed:
    - makedirs: true
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        - ReadWritePaths=/srv/www/monitor-internal/promact-out

promact:
  service.running:
    - enable: true
    - watch:
        - file: /etc/opt/promact/config.yaml
        - file: /etc/systemd/system/promact.service.d/salt.conf
