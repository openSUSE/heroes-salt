include:
  - profile.pagure.redis

pagure_pgks:
  pkg.installed:
    - pkgs:
      - pagure
      - pagure-web-nginx

pagure_conf:
  file.managed:
    - name: /etc/pagure/pagure.cfg
    - source: salt://profile/pagure/files/pagure.cfg
    - template: jinja
    - require_in:
      - service: pagure_web_service
    - watch_in:
      - module: pagure_web_restart

pagure_alembic_conf:
  file.managed:
    - name: /etc/pagure/alembic.cfg
    - source: salt://profile/pagure/files/alembic.cfg
    - template: jinja
    - require_in:
      - service: pagure_web_service
    - watch_in:
      - module: pagure_web_restart

pagure_database_setup:
  cmd.run:
    - name: python3 /usr/share/pagure/pagure_createdb.py -c /etc/pagure/pagure.cfg -i /etc/pagure/alembic.ini

{% set services = ['pagure_web', 'pagure_docs_web', 'pagure_worker', 'pagure_authorized_keys_worker', 'pagure_api_key_expire_mail.timer', 'pagure_mirror_project_in.timer'] %}

{% for service in services %}
{{ service }}_service:
  service.running:
    - name: {{ service }}
    - enable: True

{{ service }}_restart:
  module.wait:
    - name: service.restart
    - m_name: {{ service }}
    - require:
      - service: {{ service }}
{% endfor %}
