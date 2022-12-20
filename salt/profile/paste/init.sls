{% set ruby = "ruby3.1" %}

paste_dependencies:
  pkg.installed:
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
      - nodejs16

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

paste_ruby_dependencies:
  cmd.run:
    - name: bundler.{{ ruby }} install
    - cwd: /srv/www/paste-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: paste

paste_db_migration:
  cmd.run:
    - name: bin/rails db:migrate
    - cwd: /srv/www/paste-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: paste

paste_assets_precompile:
  cmd.run:
    - name: bin/rails assets:precompile
    - cwd: /srv/www/paste-o-o
    - env:
      - RAILS_ENV: 'production'
    - runas: paste

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

{% for config in ['site', 'storage', 'database'] %}
/srv/www/paste-o-o/config/{{ config }}.yml:
  file.managed:
    - source: salt://profile/paste/files/{{ config }}.yml
    - template: jinja
    - user: paste
    - require_in:
      - service: paste_service
    - watch_in:
      - module: paste_restart
{% endfor %}

/srv/www/paste-o-o/config/master.key:
  file.managed:
    - contents_pillar: profile:paste:master_key
    - mode: 640
    - user: paste

/srv/www/paste-o-o/config/credentials.yml.enc:
  file.managed:
    - contents_pillar: profile:paste:credentials_yml_enc
    - mode: 640
    - user: paste

paste_service:
  service.running:
    - name: paste.service
    - enable: True

paste_restart:
  module.wait:
    - name: service.restart
    - m_name: paste.service
    - require:
      - service: paste_service

paste_sidekiq_service:
  service.running:
    - name: paste-sidekiq.service
    - enable: True
    - require:
      - service: paste_service

paste_sidekiq_restart:
  module.wait:
    - name: service.restart
    - m_name: paste-sidekiq.service
    - require:
      - service: paste_service
      - service: paste_sidekiq_service
