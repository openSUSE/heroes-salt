mailman_pgks:
  pkg.installed:
    - pkgs:
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

/usr/bin/mailman digests --periodic:
  cron.present:
    - user: mailman
    - minute: 0
    - hour: 0

/path/to/mailman notify:
  cron.present:
    - user: mailman
    - minute: 0
    - hour: 8

django-admin runjobs hourly  --pythonpath /var/lib/mailman --settings settings:
  cron.present:
    - user: mailman
    - minute: 0

django-admin runjobs daily   --pythonpath /var/lib/mailman --settings settings:
 cron.present:
    - user: mailman
    - minute: 0
    - hour: 0

django-admin runjobs weekly  --pythonpath /var/lib/mailman --settings settings:
 cron.present:
    - user: mailman
    - minute: 0
    - hour: 0
    - dayweek: 0

django-admin runjobs monthly --pythonpath /var/lib/mailman --settings settings:
 cron.present:
    - user: mailman
    - minute: 0
    - hour: 0
    - daymonth: 0

django-admin runjobs yearly  --pythonpath /var/lib/mailman --settings settings:
 cron.present:
    - user: mailman
    - minute: 0
    - hour: 0
    - daymonth: 0
    - month: 0

django-admin runjobs minutely  --pythonpath /var/lib/mailman --settings settings:
 cron.present:
    - user: mailman

django-admin runjobs quarter_hourly --pythonpath /var/lib/mailman --settings settings:
 cron.present:
    - user: mailman
    - minute: '0,15,30,45'
