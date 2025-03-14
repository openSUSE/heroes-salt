{%- set python = 'python312' %}

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
      - uwsgi
      - {{ python }}-mailman-hyperkitty
      - {{ python }}-mailman-web
      - {{ python }}-mailmanclient
      - {{ python }}-psycopg2
      - {{ python }}-pysolr
