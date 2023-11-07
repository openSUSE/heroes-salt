redis_pgks:
  pkg.installed:
    - pkgs:
      - redis7

redis_config_file:
  file.managed:
    - name: /etc/redis/default.conf
    - source: /etc/redis/default.conf.example
    - user: redis
    - group: redis
    - replace: False

redis_service:
  service.running:
    - name: redis@default
    - enable: True
    - require:
      - file: redis_config_file
