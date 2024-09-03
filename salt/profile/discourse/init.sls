{%- from 'macros.jinja' import puma_service_dropin %}

discourse_pkgs:
  pkg.installed:
    - pkgs:
      - discourse
      - discourse-plugin-prometheus
      - discourse-plugin-stopforumspam
      - ruby3.3-rubygem-discourse_mail_receiver
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

discourse_puma_rb:
  file.comment:
    - name: /srv/www/vhosts/discourse/config/puma.rb
    - regex: ^\s+stdout_redirect

{{ puma_service_dropin('discourse-puma') }}

discourse_target:
  service.running:
    - name: discourse.target
    - enable: True

discourse_puma_service:
  service.running:
    - name: discourse-puma
    - enable: True
    - watch:
        - file: discourse_puma_rb
        - file: discourse-puma.service_custom

discourse_sidekiq_service:
  service.running:
    - name: discourse-sidekiq
    - enable: True
    - require:
        - pkg: discourse_pkgs

discourse_collector_acl:
  file.managed:
    - name: /etc/systemd/system/discourse-prometheus-collector.service.d/salt.conf
    - makedirs: True
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        - IPAddressAllow=2a07:de40:b27e:1203::50

discourse_prometheus_collector:
  service.running:
    - name: discourse-prometheus-collector
    - enable: True
    - require:
        - pkg: discourse_pkgs
    - watch:
        - file: discourse_collector_acl
