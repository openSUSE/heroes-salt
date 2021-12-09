helios:
  pkg.installed:
    - pkgs:
      - helios-server
      - helios-server-uwsgi
      - rabbitmq-server
      - python3-dbm  # needed by celeryd

/usr/lib/python3.6/site-packages/helios-server/settings.py:
  file.managed:
    - listen_in:
      - service: helios-server-uwsgi
      - service: helios-celeryd
    - source: salt://profile/helios/files/settings.py
    - template: jinja

/etc/systemd/system/helios-celeryd.service:
  file.managed:
    - source: salt://profile/helios/files/helios-celeryd.service
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/helios-celeryd.service

helios-celeryd:
  group.present:
    - system: True
  user.present:
    - gid: helios-celeryd
    - system: True
  service.running:
    - enable: True
    - watch:
      - module: /etc/systemd/system/helios-celeryd.service

helios-server-uwsgi:
  service.running:
    - enable: True

rabbitmq-server:
  service.running:
    - enable: True

# manual steps for database setup (also after upgrades):
# run the two "python3 manage.py" commands listed in /usr/lib/python*/site-packages/helios-server/reset.sh
