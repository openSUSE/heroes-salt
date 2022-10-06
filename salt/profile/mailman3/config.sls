mailman_conf_file:
  file.managed:
    - name: /etc/mailman.cfg
    - source: salt://profile/mailman3/files/mailman.cfg
    - template: jinja
    - require_in:
      - service: mailman_service
    - watch_in:
      - module: mailman_restart

mailman_web_settings_file:
  file.managed:
    - name: /srv/www/webapps/mailman/web/settings.py
    - source: salt://profile/mailman3/files/settings.py
    - template: jinja
    - require_in:
      - service: mailman_web_service
    - watch_in:
      - module: mailman_web_restart

mailman_web_disable_signup:
  file.managed:
    - name: /srv/www/webapps/mailman/web/django_fedora_nosignup.py
    - source: salt://profile/mailman3/files/django_fedora_nosignup.py

mailman_hyperkitty_conf:
  file.managed:
    - name: /etc/hyperkitty.cfg
    - source: salt://profile/mailman3/files/hyperkitty.cfg
    - template: jinja
    - require_in:
      - service: mailman_web_service
    - watch_in:
      - module: mailman_web_restart

/srv/www/webapps/mailman/web/secret.txt:
  file.managed:
    - contents_pillar: profile:mailman3:secret_txt
    - mode: 640
    - user: mailmanweb
    - group: mailmanweb

mailman_nginx_conf:
  file.managed:
    - name: /etc/nginx/conf.d/lists.opensuse.org.conf
    - source: salt://profile/mailman3/files/nginx.conf
    - require_in:
      - service: mailman_web_service
    - watch_in:
      - module: mailman_web_restart
