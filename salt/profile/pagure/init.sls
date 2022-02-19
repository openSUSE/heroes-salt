include:
  - profile.crtmgr
  - profile.pagure.redis

pagure_pgks:
  pkg.installed:
    - pkgs:
      - pagure
      - pagure-web-nginx
      - pagure-theme-chameleon
      - pagure-ci
      - pagure-ev
      - pagure-loadjson
      - pagure-logcom
      - pagure-milters
      - pagure-mirror
      - pagure-webhook

pagure_conf:
  file.managed:
    - name: /etc/pagure/pagure.cfg
    - source: salt://profile/pagure/files/pagure.cfg
    - template: jinja
    - group: git
    - mode: '0640'
    - require_in:
      - service: pagure_web_service
    - watch_in:
      - module: pagure_web_restart

pagure_ssl_conf:
  file.managed:
    - name: /etc/nginx/ssl-config
    - source: salt://profile/pagure/files/ssl-config
    - require_in:
      - service: pagure_web_service
    - watch_in:
      - module: pagure_web_restart

pagure_alembic_conf:
  file.managed:
    - name: /etc/pagure/alembic.ini
    - source: salt://profile/pagure/files/alembic.ini
    - template: jinja
    - group: git
    - mode: '0640'
    - require_in:
      - service: pagure_web_service
    - watch_in:
      - module: pagure_web_restart

pagure_database_setup:
  cmd.run:
    - name: python3 /usr/share/pagure/pagure_createdb.py -c /etc/pagure/pagure.cfg

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
