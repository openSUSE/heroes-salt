redis_pgks:
  pkg.installed:
    - pkgs:
      - redis

redis_config_file:
  file.managed:
    - name: /etc/redis/default.conf
    - source: /etc/redis/default.conf.example
    - user: redis
    - group: redis
    - replace: False
    - require_in:
      - service: redis_service

redis_service:
  service.running:
    - name: redis@default
    - enable: True

redis_restart:
  module.wait:
    - name: service.restart
    - m_name: redis@default
    - require:
      - service: redis_service
