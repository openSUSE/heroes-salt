{%- set python = grains['system_python'] %}

mailman_pkgs:
  pkg.installed:
    - resolve_capabilities: True
    - pkgs:
      # html => text for mailman
      - lynx
      - memcached
      - nginx-rewrite-lists-openSUSE
      - uwsgi
      - {{ python }}-HyperKitty
      - {{ python }}-mailman
      - {{ python }}-mailman-hyperkitty
      - {{ python }}-mailman-web
      - {{ python }}-mailmanclient
      - {{ python }}-postorius
      - {{ python }}-psycopg2
      - {{ python }}-xapian
