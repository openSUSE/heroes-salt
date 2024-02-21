{%- set python_version = salt['cmd.run']("python3 -c 'from platform import python_version_tuple; print(str().join(python_version_tuple()[:2]))'") %}

telegram_pkgs:
  pkg.installed:
    - pkgs:
      - python{{ python_version }}-mautrix-telegram
      # Required for webm for stickers
      - ffmpeg-5

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
