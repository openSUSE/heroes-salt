memcached:
  pkg.installed:
    - pkgs:
      - memcached
  service.running:
    - enable: True
