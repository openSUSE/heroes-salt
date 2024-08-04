{%- from 'macros.jinja' import puma_service_dropin %}
{%- set ruby = 'ruby2.7' %}

tsp_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - tar
      - make
      - gcc-c++
      - zlib-devel
      - libQt5WebKit5-devel
      - postgresql-devel
      - postgresql-server-devel
      - {{ ruby }}-devel
      - system-user-wwwrun

tsp_user:
  user.present:
    - name: tsp

/srv/www/travel-support-program:
  file.directory:
    - user: tsp

/var/cache/tsp:
  file.directory:
    - user: wwwrun

/var/log/tsp:
  file.directory:
    - user: wwwrun

https://github.com/openSUSE/travel-support-program.git:
  git.latest:
    - branch: master
    - target: /srv/www/travel-support-program
    - rev: master
    - user: tsp

/srv/www/travel-support-program/tmp:
  file.directory:
    - user: tsp

/srv/www/travel-support-program/log:
  file.directory:
    - user: tsp

tsp_ruby_dependencies:
  cmd.run:
    - name: bundler.{{ ruby }} install --deployment
    - cwd: /srv/www/travel-support-program
    - runas: tsp
    - unless: bundler.{{ ruby }} check

tsp_db_migration:
  cmd.run:
    - name: rake.{{ ruby }} db:migrate
    - cwd: /srv/www/travel-support-program
    - env:
      - RAILS_ENV: 'production'
    - runas: tsp
    - require:
        - cmd: tsp_ruby_dependencies
    - onlyif: rake.{{ ruby }} db:migrate:status | grep down

tsp_assets_precompile:
  cmd.run:
    - name: rake.{{ ruby }} assets:precompile
    - cwd: /srv/www/travel-support-program
    - env:
      - RAILS_ENV: 'production'
    - runas: tsp
    - onchanges:
        - git: https://github.com/openSUSE/travel-support-program.git
    - require:
        - cmd: tsp_ruby_dependencies

{% for service in ['tsp', 'tsp-delayed-job'] %}
/etc/systemd/system/{{ service }}.service:
  file.managed:
    - source: salt://profile/tsp/files/{{ service }}.service
    - template: jinja
    - context:
        ruby: {{ ruby }}
    - require_in:
      - service: tsp_service
{% endfor %}

/srv/www/travel-support-program/config/site.yml:
  file.managed:
    - source: salt://profile/tsp/files/site.yml
    - template: jinja
    - user: tsp
    - require_in:
      - service: tsp_service

/srv/www/travel-support-program/config/database.yml:
  file.managed:
    - source: salt://profile/tsp/files/database.yml
    - template: jinja
    - user: tsp
    - require_in:
      - service: tsp_service

{{ puma_service_dropin('tsp') }}

tsp_service:
  service.running:
    - names:
        - tsp
        - tsp-delayed-job
    - enable: True
    - watch:
        - file: /etc/systemd/system/tsp.service
        - file: /etc/systemd/system/tsp-delayed-job.service
        - file: /srv/www/travel-support-program/config/site.yml
        - file: /srv/www/travel-support-program/config/database.yml
        - file: tsp.service_custom
