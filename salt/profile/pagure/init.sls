include:
  - .ssh

pagure_packages:
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

pagure_configuration:
  file.managed:
    - names:
        - /etc/pagure/pagure.cfg:
            - source: salt://profile/pagure/files/pagure.cfg.jinja
        - /etc/pagure/alembic.ini:
            - source: salt://profile/pagure/files/alembic.ini.jinja
    - template: jinja
    - group: git
    - mode: '0640'
    - watch_in:
      - service: pagure_web_service

pagure_database_setup:
  cmd.run:
    - name: python3 /usr/share/pagure/pagure_createdb.py -c /etc/pagure/pagure.cfg
    - onchanges:
        - pkg: pagure_packages

pagure_gunicorn_override:
  file.managed:
    - names:
        - /etc/systemd/system/pagure_web.service.d/salt.conf
    - makedirs: True
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        - ExecStart=
        - >-
          ExecStart =
          /usr/bin/gunicorn
          --workers=8
          --timeout=60
          --env PAGURE_CONFIG=/etc/pagure/pagure.cfg
          --access-logfile /var/log/pagure/access_web.log
          --error-logfile /var/log/pagure/error_web.log
          --bind unix:/srv/gitolite/.pagure_web.sock
          "pagure.flask_app:create_app()"
    - watch_in:
      - service: pagure_web_service

pagure_worker_override:
  file.managed:
    - names:
        - /etc/systemd/system/pagure_worker.service.d/salt.conf
    - makedirs: True
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        - Environment=TMPDIR=/data/pagure/tmp
    - watch_in:
      - service: pagure_worker_service

# pagure_milter service runs as postfix:postfix (consider patching that to something more sensible upstream)
pagure_postfix_acl:
  acl.present:
    - name: /etc/pagure/pagure.cfg
    - acl_type: group
    - acl_name: postfix
    - perms: r
    - require:
      - pkg: pagure_packages
    - require_in:
      - service: pagure_milter_service

{%- set services = ['pagure_web', 'pagure_docs_web', 'pagure_worker', 'pagure_authorized_keys_worker', 'pagure_milter', 'pagure_api_key_expire_mail.timer', 'pagure_mirror_project_in.timer'] %}

{%- for service in services %}
{{ service }}_service:
  service.running:
    - name: {{ service }}
    - enable: True
{%- endfor %}

pagure_robots:
  file.managed:
    - name: /srv/www/htdocs/robots.txt
    - contents:
        - 'User-agent: *'
        - 'Disallow: /'
