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
      - {{ ruby }}-rubygem-bundler
      - system-user-wwwrun

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
    - rev: master
    - user: paste

paste_ruby_dependencies:
  cmd.run:
    - name: bundler.{{ ruby }} install
    - cwd: /srv/www/paste-o-o
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

/srv/www/paste-o-o/config/site.yml:
  file.managed:
    - source: salt://profile/paste/files/site.yml
    - template: jinja
    - user: paste
    - require_in:
      - service: paste_service
    - watch_in:
      - module: paste_restart

/srv/www/paste-o-o/config/storage.yml:
  file.managed:
    - source: salt://profile/paste/files/storage.yml
    - template: jinja
    - user: paste
    - require_in:
      - service: paste_service
    - watch_in:
      - module: paste_restart

/srv/www/paste-o-o/config/database.yml:
  file.managed:
    - source: salt://profile/paste/files/database.yml
    - template: jinja
    - user: paste
    - require_in:
      - service: paste_service
    - watch_in:
      - module: paste_restart

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
