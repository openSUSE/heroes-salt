tsp_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - ruby-devel
      - ruby2.5-rubygem-bundler
      - ruby2.5-rubygem-pg
      - ruby2.5-rubygem-puma

https://github.com/openSUSE/travel-support-program.git:
  git.latest:
    - branch: master
    - target: /srv/www/travel-support-program
    - rev: master
    - user: wwwrun

tsp_ruby_dependencies:
  cmd.run:
    - name: bundler install --deployment
    - cwd: /srv/www/travel-support-program
    - runas: wwwrun

/etc/systemd/system/tsp.service:
  file.managed:
    - source: salt://profile/tsp/files/tsp.service
    - require_in:
      - service: tsp_service

/srv/www/travel-support-program/config/site.yml:
  file.managed:
    - source: salt://profile/tsp/files/site.yml
    - template: jinja
    - user: wwwrun
    - require_in:
      - service: tsp_service
    - watch_in:
      - module: tsp_restart

/srv/www/travel-support-program/config/database.yml:
  file.managed:
    - source: salt://profile/tsp/files/database.yml
    - template: jinja
    - user: wwwrun
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
