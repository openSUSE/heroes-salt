tsp_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - tar
      - make
      - gcc-c++
      - zlib-devel
      - libqt4-devel
      - libQtWebKit4-devel
      - postgresql-devel
      - postgresql-server-devel
      - ruby-devel
      - ruby2.5-rubygem-bundler
      - ruby2.5-rubygem-pg
      - ruby2.5-rubygem-puma
      - system-user-wwwrun

tsp_user:
  user.present:
    - name: tsp

/srv/www/travel-support-program:
  file.directory:
    - user: tsp

/var/cache/tsp:
  file.directory:
    - user: tsp

/var/log/tsp:
  file.directory:
    - user: tsp

https://github.com/openSUSE/travel-support-program.git:
  git.latest:
    - branch: master
    - target: /srv/www/travel-support-program
    - rev: master
    - user: tsp

/srv/www/travel-support-program/tmp:
  file.directory:
    - user: wwwrun

/srv/www/travel-support-program/log:
  file.directory:
    - user: wwwrun

tsp_ruby_dependencies:
  cmd.run:
    - name: bundler install --deployment
    - cwd: /srv/www/travel-support-program
    - runas: tsp

tsp_db_migration:
  cmd.run:
    - name: rake db:migrate
    - cwd: /srv/www/travel-support-program
    - env: RAILS_ENV=production
    - runas: tsp

/etc/systemd/system/tsp.service:
  file.managed:
    - source: salt://profile/tsp/files/tsp.service
    - require_in:
      - service: tsp_service

/etc/systemd/system/tsp.socket:
  file.managed:
    - source: salt://profile/tsp/files/tsp.socket
    - require_in:
      - service: tsp_service

/srv/www/travel-support-program/config/puma.rb:
  file.managed:
    - source: salt://profile/tsp/files/puma.rb
    - user: tsp
    - require_in:
      - service: tsp_service

/srv/www/travel-support-program/config/site.yml:
  file.managed:
    - source: salt://profile/tsp/files/site.yml
    - template: jinja
    - user: tsp
    - require_in:
      - service: tsp_service
    - watch_in:
      - module: tsp_restart

/srv/www/travel-support-program/config/database.yml:
  file.managed:
    - source: salt://profile/tsp/files/database.yml
    - template: jinja
    - user: tsp
    - require_in:
      - service: tsp_service
    - watch_in:
      - module: tsp_restart

tsp_service:
  service.running:
    - name: tsp
    - enable: True

tsp_restart:
  module.wait:
    - name: service.restart
    - m_name: tsp
    - require:
      - service: tsp_service
