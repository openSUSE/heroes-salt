memcached:
  pkg.installed:
    - pkgs:
      - memcached
      - monitoring-plugins-memcached
  service.running:
    - enable: True

/etc/sysconfig/memcached:
  file.replace:
    - ignore_if_missing: {{ opts['test'] }}
    - pattern: ^MEMCACHED_PARAMS=.*$
    - repl: MEMCACHED_PARAMS="-l 127.0.0.1 -m 4096"
    - listen_in:
      - service: memcached
