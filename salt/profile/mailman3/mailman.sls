mailman_pkgs:
  pkg.installed:
    - resolve_capabilities: True
    - pkgs:
      - uwsgi
      - python3-xapian
      - python3-psycopg2
      - python3-mailman
      - python3-mailmanclient
      - python3-postorius
      - python3-mailman-web
      - python3-HyperKitty
      - python3-mailman-hyperkitty
      # html => text for mailman
      - lynx
      - memcached
      - nginx-rewrite-lists-openSUSE
