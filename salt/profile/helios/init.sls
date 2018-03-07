helios:
  pkg.installed:
    - pkgs:
      - helios-server
      - helios-server-uwsgi

helios-server-uwsgi:
  service.running:
    - enable: True

/usr/lib/python2.7/site-packages/helios-server/settings.py:
  file.managed:
    - listen_in:
      - service: helios-server-uwsgi
    - source: salt://profile/helios/files/settings.py
    - template: jinja

helios-celeryd:
  group.present:
    - system: True
  user.present:
    - gid: helios-celeryd
    - system: True

/etc/systemd/system/helios-celeryd.service:
  file.managed:
    - source: salt://profile/helios/files/helios-celeryd.service
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/helios-celeryd.service

helios-celeryd.service:
  service.running:
    - enable: True
    - watch:
      - module: /etc/systemd/system/helios-celeryd.service

# manual steps for database setup:
# run the two "python manage.py" commands listed in /usr/lib/python2.7/site-packages/helios-server/reset.sh
