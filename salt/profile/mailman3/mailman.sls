{%- set python = grains['system_python'] %}

mailman_pkgs:
  pkg.installed:
    - resolve_capabilities: True
    - pkgs:
      - HyperKitty
      # html => text for mailman
      - lynx
      - mailman3
      - nginx-rewrite-lists-openSUSE
      - postorius
      - python3-mailman-hyperkitty
      - python3-mailman-web
      - uwsgi
      - {{ python }}-mailmanclient
      - {{ python }}-psycopg2
      - {{ python }}-xapian
