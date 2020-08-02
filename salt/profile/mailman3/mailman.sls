mailman_pgks:
  pkg.installed:
    - pkgs:
      - uwsgi
      - python3-xapian
      - python3-psycopg2
      - python3-mailman
      - python3-mailmanclient
      - python3-postorius
      - python3-mailman-web
      - python3-HyperKitty
      - python3-mailman-hyperkitty
      # html => text for mailman
      - lynx
      - memcached

mailman:
  user.present:
    - home: /var/lib/mailman
    - uid: 4200
  group.present:
    - system: True
    - gid: 4200
    - members:
      - mailman

mailman_digest:
  cron.present:
    - name: /usr/bin/mailman digests --periodic
    - user: mailman
    - minute: 0
    - hour: 0

mailman_notify:
  cron.present:
    - name: /usr/bin/mailman notify
    - user: mailman
    - minute: 0
    - hour: 8

mailman_hourly:
  cron.present:
    - name: django-admin runjobs hourly --pythonpath /var/lib/mailman --settings settings
    - user: mailman
    - minute: 0

mailman_daily:
  cron.present:
    - name: django-admin runjobs daily --pythonpath /var/lib/mailman --settings settings
    - user: mailman
    - minute: 0
    - hour: 0

mailman_weekly:
  cron.present:
    - name: django-admin runjobs weekly --pythonpath /var/lib/mailman --settings settings
    - user: mailman
    - minute: 0
    - hour: 0
    - dayweek: 0

mailman_monthly:
  cron.present:
    - name: django-admin runjobs monthly --pythonpath /var/lib/mailman --settings settings
    - user: mailman
    - minute: 0
    - hour: 0
    - daymonth: 1

mailman_yearly:
  cron.present:
    - name: django-admin runjobs yearly --pythonpath /var/lib/mailman --settings settings
    - user: mailman
    - minute: 0
    - hour: 0
    - daymonth: 1
    - month: 1

mailman_minutely:
  cron.present:
    - name: django-admin runjobs minutely --pythonpath /var/lib/mailman --settings settings
    - user: mailman

mailman_quarter_hourly:
  cron.present:
    - name: django-admin runjobs quarter_hourly --pythonpath /var/lib/mailman --settings settings
    - user: mailman
    - minute: '0,15,30,45'
