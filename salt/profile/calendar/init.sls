{% set ruby = "ruby3.2" %}

calendar_dependencies:
  pkg.installed:
    - resolve_capabilities: True
    - pkgs:
      - git
      - tar
      - make
      - gcc-c++
      - zlib-devel
      - postgresql-devel
      - postgresql-server-devel
      - {{ ruby }}-devel
      - system-user-wwwrun
      - nodejs20
      - libyaml-devel

/srv/www/calendar-o-o:
  file.directory:
    - user: calendar

https://github.com/openSUSE/calendar-o-o.git:
  git.latest:
    - branch: main
    - target: /srv/www/calendar-o-o
    - rev: main
    - user: calendar
    - force_fetch: True

calendar_bundler_deployment:
  cmd.run:
    - name: bundler.{{ ruby }} config set --local path 'vendor/bundle'
    - cwd: /srv/www/calendar-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: calendar
    - creates: /srv/www/calendar-o-o/.bundle/config

calendar_ruby_dependencies:
  cmd.run:
    - name: bundler.{{ ruby }} install
    - cwd: /srv/www/calendar-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: calendar
    - unless: bundler.{{ ruby }} check

calendar_db_migration:
  cmd.run:
    - name: bin/rails db:migrate
    - cwd: /srv/www/calendar-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: calendar
    - onlyif: bin/rails db:migrate:status | grep down

calendar_assets_precompile:
  cmd.run:
    - name: bin/rails assets:precompile
    - cwd: /srv/www/calendar-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: calendar
    - creates: /srv/www/calendar-o-o/public/assets/

/etc/systemd/system/calendar.service:
  file.managed:
    - source: salt://profile/calendar/files/calendar.service
    - template: jinja
    - context:
        ruby: {{ ruby }}
    - watch_in:
      - service: calendar_service

/etc/systemd/system/calendar-sidekiq.service:
  file.managed:
    - source: salt://profile/calendar/files/calendar-sidekiq.service
    - template: jinja
    - context:
        ruby: {{ ruby }}
    - watch_in:
      - service: calendar_sidekiq_service

/etc/systemd/system/calendar-clockwork.service:
  file.managed:
    - source: salt://profile/calendar/files/calendar-clockwork.service
    - template: jinja
    - context:
        ruby: {{ ruby }}
    - watch_in:
      - service: calendar_clockwork_service

{%- for config in ['site', 'database'] %}
/srv/www/calendar-o-o/config/{{ config }}.yml:
  file.managed:
    - source: salt://profile/calendar/files/{{ config }}.yml
    - template: jinja
    - user: calendar
    - watch_in:
      - service: calendar_service
{%- endfor %}

/srv/www/calendar-o-o/config/master.key:
  file.managed:
    - contents_pillar: profile:calendar:master_key
    - mode: '0640'
    - user: calendar

/srv/www/calendar-o-o/config/credentials.yml.enc:
  file.managed:
    - contents_pillar: profile:calendar:credentials_yml_enc
    - mode: '0640'
    - user: calendar
    - contents_newline: False

calendar_service:
  service.running:
    - name: calendar.service
    - enable: True
    - watch:
        - cmd: calendar_ruby_dependencies
        - cmd: calendar_assets_precompile
        - file: /srv/www/calendar-o-o/config/master.key
        - file: /srv/www/calendar-o-o/config/credentials.yml.enc

calendar_sidekiq_service:
  service.running:
    - name: calendar-sidekiq.service
    - enable: True
    - require:
      - service: calendar_service
    - watch:
        - cmd: calendar_ruby_dependencies

calendar_clockwork_service:
  service.running:
    - name: calendar-clockwork.service
    - enable: True
    - require:
      - service: calendar_service
    - watch:
        - cmd: calendar_ruby_dependencies
