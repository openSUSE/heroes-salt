# The profile postgress/server manages some basic postgress
#  files for each server.

{% set id = salt['grains.get']('id').replace('.', '_')  %}

/etc/postgresql/pg_hba.conf:
  file.managed:
    - source: salt://profile/postgresql/files/postgresql/pg_hba.conf
    - user: root
    - group: postgres
    - mode: '0640'

/etc/postgresql/pg_ident.conf:
  file.managed:
    - source: salt://profile/postgresql/files/postgresql/pg_ident.conf
    - user: root
    - group: postgres
    - mode: '0640'

/etc/postgresql/postgresql.auto.conf:
  file.managed:
    - source: salt://profile/postgresql/files/postgresql/postgresql.auto.conf
    - user: root
    - group: postgres
    - mode: '0640'

/etc/postgresql/postgresql.conf:
  file.managed:
    - source: salt://profile/postgresql/files/postgresql/postgresql.conf.jinja
    - template: jinja
    - user: root
    - group: postgres
    - mode: '0640'

postgresql.service:
  service.running:
    - name: postgresql
    - enable: True
    - watch:
      - file: /etc/postgresql/pg_hba.conf
      - file: /etc/postgresql/pg_ident.conf
      - file: /etc/postgresql/postgresql.auto.conf
      - file: /etc/postgresql/postgresql.conf
