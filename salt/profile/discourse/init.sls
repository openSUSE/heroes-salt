discourse_pgks:
  pkg.installed:
    - pkgs:
      - discourse
      - ruby2.7-rubygem-discourse_mail_receiver

discourse_config:
  file.managed:
    - name: /srv/www/vhosts/discourse/config/discourse.conf
    - source: salt://profile/discourse/files/discourse.conf
    - template: jinja
    - require_in:
      - service: discourse_target
    - watch_in:
      - module: discourse_target

discourse_mail_receiver_settings:
  file.managed:
    - name: /etc/postfix/mail-receiver-environment.json
    - source: salt://profile/discourse/files/mail-receiver-environment.json
    - template: jinja
    - require_in:
      - service: discourse_target
    - watch_in:
      - module: discourse_target

discourse_target:
  service.running:
    - name: discourse.target
    - enable: True

discourse_update_service:
  service.running:
    - name: discourse-update
    - enable: True

discourse_puma_service:
  service.running:
    - name: discourse-puma
    - enable: True

discourse_sidekiq_service:
  service.running:
    - name: discourse-puma
    - enable: True

discourse_restart:
  module.wait:
    - name: service.restart
    - m_name: discourse.target
    - require:
      - service: discourse_update_service
      - service: discourse_puma_service
      - service: discourse_sidekiq_service
      - service: discourse_target
