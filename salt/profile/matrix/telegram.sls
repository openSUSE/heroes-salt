telegram_pkgs:
  pkg.installed:
    - resolve_capabilities: True
    - pkgs:
      - python3-mautrix-telegram
      # Required for webm for stickers
      - ffmpeg

telegram_conf_file:
  file.managed:
    - name: /etc/mautrix-telegram/config.yaml
    - source: salt://profile/matrix/files/config-telegram.yaml
    - template: jinja
    - user: synapse
    - require_in:
      - service: telegram_service

telegram_appservice_file:
  file.managed:
    - name: /etc/mautrix-telegram/registration.yaml
    - source: salt://profile/matrix/files/appservice-telegram.yaml
    - user: synapse
    - template: jinja

synapse_appservice_telegram_file:
  file.managed:
    - name: /etc/matrix-synapse/appservices/appservice-telegram.yaml
    - source: salt://profile/matrix/files/appservice-telegram.yaml
    - template: jinja

telegram_service:
  service.running:
    - name: telegram
    - enable: True
    - require:
      - service: synapse_service
    - watch:
      - file: telegram_conf_file
      - file: telegram_appservice_file
      - file: synapse_appservice_telegram_file
