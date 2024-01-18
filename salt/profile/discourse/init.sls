discourse_pgks:
  pkg.installed:
    - pkgs:
      - discourse
      - ruby3.2-rubygem-discourse_mail_receiver
      - nginx-module-brotli

discourse_config:
  file.managed:
    - name: /srv/www/vhosts/discourse/config/discourse.conf
    - source: salt://profile/discourse/files/discourse.conf
    - template: jinja
    - watch_in:
      - service: discourse_target

discourse_mail_receiver_settings:
  file.managed:
    - name: /etc/postfix/mail-receiver-environment.json
    - source: salt://profile/discourse/files/mail-receiver-environment.json
    - template: jinja
    - watch_in:
      - service: discourse_target

discourse_mail_transport:
  file.managed:
    - name: /etc/postfix/transport
    - contents: 'forums.opensuse.org  discourse:'
    - user: root
    - group: root
    - mode: '0644'
    - replace: True
    - watch_in:
      - service: discourse_target

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

discourse_puma_rb:
  file.comment:
    - name: /srv/www/vhosts/discourse/config/puma.rb
    - regex: ^stdout_redirect

discourse_puma_service_override:
  file.managed:
    - name: /etc/systemd/system/discourse-puma.service.d/salt.conf
    - makedirs: True
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        - Environment=RAILS_LOG_TO_STDOUT=1

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
    - watch:
        - file: discourse_puma_rb
        - file: discourse_puma_service_override

discourse_sidekiq_service:
  service.running:
    - name: discourse-puma
    - enable: True
