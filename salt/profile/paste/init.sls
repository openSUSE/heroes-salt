{%- from 'macros.jinja' import puma_service_dropin %}
{%- set ruby = "ruby3.1" %}

paste_dependencies:
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

paste_user:
  user.present:
    - name: paste

/srv/www/paste-o-o:
  file.directory:
    - user: paste

https://github.com/openSUSE/paste-o-o.git:
  git.latest:
    - branch: main
    - target: /srv/www/paste-o-o
    - rev: main
    - user: paste

paste_bundler_deployment:
  cmd.run:
    - name: bundler.{{ ruby }} config set --local path 'vendor/bundle'
    - cwd: /srv/www/paste-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: paste
    - creates: /srv/www/paste-o-o/.bundle/config

paste_ruby_dependencies:
  cmd.run:
    - name: bundler.{{ ruby }} install
    - cwd: /srv/www/paste-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: paste
    - unless: bundler.{{ ruby }} check

paste_db_migration:
  cmd.run:
    - name: bin/rails db:migrate
    - cwd: /srv/www/paste-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: paste
    - onlyif: bin/rails db:migrate:status | grep down

paste_assets_precompile:
  cmd.run:
    - name: bin/rails assets:precompile
    - cwd: /srv/www/paste-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: paste
    - creates: /srv/www/paste-o-o/public/assets/

/etc/systemd/system/paste.service:
  file.managed:
    - source: salt://profile/paste/files/paste.service
    - template: jinja
    - context:
        ruby: {{ ruby }}
    - require_in:
      - service: paste_service

/etc/systemd/system/paste-sidekiq.service:
  file.managed:
    - source: salt://profile/paste/files/paste-sidekiq.service
    - template: jinja
    - context:
        ruby: {{ ruby }}
    - require_in:
      - service: paste_sidekiq_service

{%- for config in ['site', 'storage', 'database'] %}
/srv/www/paste-o-o/config/{{ config }}.yml:
  file.managed:
    - source: salt://profile/paste/files/{{ config }}.yml
    - template: jinja
    - user: paste
    - watch_in:
      - service: paste_service
{%- endfor %}

/srv/www/paste-o-o/config/master.key:
  file.managed:
    - contents_pillar: profile:paste:master_key
    - mode: '0640'
    - user: paste

/srv/www/paste-o-o/config/credentials.yml.enc:
  file.managed:
    - contents_pillar: profile:paste:credentials_yml_enc
    - mode: '0640'
    - user: paste
    - contents_newline: False

{{ puma_service_dropin('paste') }}

paste_service:
  service.running:
    - name: paste.service
    - enable: True
    - watch:
        - file: paste_puma_service_custom

paste_sidekiq_service:
  service.running:
    - name: paste-sidekiq.service
    - enable: True
    - require:
        - service: paste_service
