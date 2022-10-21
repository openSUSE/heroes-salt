discourse_pgks:
  pkg.installed:
    - pkgs:
      - discourse
      - ruby2.7-rubygem-discourse_mail_receiver
      - nginx-module-brotli

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

discourse_mail_transport:
  file.managed:
    - name: /etc/postfix/transport
    - contents: 'forums.opensuse.org  discourse:'
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - require_in:
      - service: discourse_target
    - watch_in:
      - module: discourse_target

discourse_mail_transport_postmap:
  cmd.run:
    - name: postmap /etc/postfix/transport
    - runas: root
    - onchanges:
      - file: discourse_mail_transport
    - watch_in:
      - service: postfix
    - require:
      - pkg: postfix

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
