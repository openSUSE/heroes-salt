/etc/prometheus/alertmanager-irc.yml:
  file.managed:
    - source: salt://profile/monitoring/prometheus/files/alertmanager-irc.yml.jinja
    - template: jinja

alertmanager-irc-relay:
  service.running:
    - enable: true
    - watch:
      - file: /etc/prometheus/alertmanager-irc.yml
