telegram_pgks:
  pkg.installed:
    - pkgs:
      - python3-mautrix-telegram
      # Required for webm for stickers
      - ffmpeg-3

telegram_conf_file:
  file.managed:
    - name: /etc/mautrix-telegram/config.yaml
    - source: salt://profile/matrix/files/config-telegram.yaml
    - template: jinja
    - user: synapse
    - require_in:
      - service: telegram_service
    - watch_in:
      - module: telegram_restart

telegram_appservice_file:
  file.managed:
    - name: /etc/mautrix-telegram/registration.yaml
    - source: salt://profile/matrix/files/appservice-telegram.yaml
    - user: synapse
    - template: jinja
    - watch_in:
      - module: telegram_restart

synapse_appservice_telegram_file:
  file.managed:
    - name: /etc/matrix-synapse/appservices/appservice-telegram.yaml
    - source: salt://profile/matrix/files/appservice-telegram.yaml
    - template: jinja
    - watch_in:
      - module: telegram_restart

telegram_service:
  service.running:
    - name: mautrix-telegram
    - enable: True
    - require:
      - service: synapse_service

telegram_restart:
  module.wait:
    - name: service.restart
    - m_name: mautrix-telegram
    - require:
      - service: synapse_service
      - service: telegram_service
