mailman_conf_file:
  file.managed:
    - name: /etc/mailman.cfg
    - source: salt://profile/mailman3/files/mailman.cfg
    - template: jinja
    - require_in:
      - service: mailman_service
    - watch_in:
      - module: mailman_restart

mailman_hyperkitty_settings_file:
  file.managed:
    - name: /srv/www/webapps/mailman/hyperkitty/settings.py
    - source: salt://profile/mailman3/files/settings.py
    - template: jinja
    - require_in:
      - service: mailman_hyperkitty_service
    - watch_in:
      - module: mailman_hyperkitty_restart

mailman_postorius_settings_file:
  file.managed:
    - name: /srv/www/webapps/mailman/postorius/settings_local.py
    - source: salt://profile/mailman3/files/settings_local.py
    - template: jinja
    - require_in:
      - service: mailman_postorius_service
    - watch_in:
      - module: mailman_postorius_restart

mailman_postorius_disable_signup:
  file.managed:
    - name: /srv/www/webapps/mailman/postorius/django_fedora_nosignup.py
    - source: salt://profile/mailman3/files/django_fedora_nosignup.py

mailman_hyperkitty_disable_signup:
  file.managed:
    - name: /srv/www/webapps/mailman/hyperkitty/django_fedora_nosignup.py
    - source: salt://profile/mailman3/files/django_fedora_nosignup.py

mailman_hyperkitty_conf:
  file.managed:
    - name: /etc/hyperkitty.cfg
    - source: salt://profile/mailman3/files/hyperkitty.cfg
    - template: jinja
    - require_in:
      - service: mailman_hyperkitty_service
    - watch_in:
      - module: mailman_hyperkitty_restart

/srv/www/webapps/mailman/postorius/secret.txt:
  file.managed:
    - contents_pillar: profile:mailman3:secret_txt
    - mode: 640
    - user: postorius
    - group: postorius

/srv/www/webapps/mailman/hyperkitty/secret.txt:
  file.managed:
    - contents_pillar: profile:mailman3:secret_txt
    - mode: 640
    - user: hyperkitty
    - group: hyperkitty

mailman_nginx_conf:
  file.managed:
    - name: /etc/nginx/conf.d/lists.opensuse.org.conf
    - source: salt://profile/mailman3/files/nginx.conf
    - require_in:
      - service: mailman_hyperkitty_service
    - watch_in:
      - module: mailman_hyperkitty_restart
