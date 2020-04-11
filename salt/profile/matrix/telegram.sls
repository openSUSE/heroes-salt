telegram_pgks:
  pkg.installed:
    - pkgs:
      - python3-mautrix-telegram
      # Required for webm for stickers
      - ffmpeg-3

/var/lib/matrix-synapse/telegram:
  file.directory:
    - user: synapse

telegram_conf_file:
  file.managed:
    - name: /var/lib/matrix-synapse/telegram/config.yaml
    - source: salt://profile/matrix/files/config-telegram.yaml
    - template: jinja
    - user: synapse
    - require:
      - file: /var/lib/matrix-synapse/telegram
    - require_in:
      - service: telegram_service
    - watch_in:
      - module: telegram_restart

telegram_appservice_file:
  file.managed:
    - name: /var/lib/matrix-synapse/telegram/telegram-registration.yaml
    - source: salt://profile/matrix/files/appservice-telegram.yaml
    - user: synapse
    - template: jinja
    - require:
      - file: /var/lib/matrix-synapse/telegram
    - watch_in:
      - module: telegram_restart

synapse_appservice_telegram_file:
  file.managed:
    - name: /etc/matrix-synapse/appservices/appservice-telegram.yaml
    - source: salt://profile/matrix/files/appservice-telegram.yaml
    - template: jinja
    - require:
      - file: /var/lib/matrix-synapse/telegram
    - watch_in:
      - module: telegram_restart

telegram_systemd_file:
  file.managed:
    - name: /etc/systemd/system/telegram.service
    - source: salt://profile/matrix/files/telegram.service
    - require_in:
      - service: telegram_service

telegram_service:
  service.running:
    - name: telegram
    - enable: True
    - require:
      - service: synapse_service

telegram_restart:
  module.wait:
    - name: service.restart
    - m_name: telegram
    - require:
      - service: synapse_service
      - service: telegram_service
