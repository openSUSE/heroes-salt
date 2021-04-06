mailman_conf_dir:
  file.directory:
    - name: /etc/mailman/

mailman_var_dir:
  file.directory:
    - name: /var/lib/mailman/

mailman_webui_dir:
  file.directory:
    - name: /var/lib/mailman_webui/

mailman_log_dir:
  file.directory:
    - name: /var/log/mailman/
    - user: mailman

mailman_lock_dir:
  file.directory:
    - name: /var/lock/mailman/
    - user: mailman

mailman_run_dir:
  file.directory:
    - name: /var/run/mailman/
    - user: mailman

mailman_spool_dir:
  file.directory:
    - name: /var/spool/mailman/
    - user: mailman

mailman_conf_file:
  file.managed:
    - name: /etc/mailman/mailman.cfg
    - source: salt://profile/mailman3/files/mailman.cfg
    - template: jinja
    - require:
      - file: mailman_conf_dir
    - require_in:
      - service: mailman_service
    - watch_in:
      - module: mailman_restart

mailman_conf_symlink_var:
  file.symlink:
    - name: /var/lib/mailman/var/etc/mailman.cfg
    - target: /etc/mailman/mailman.cfg

mailman_conf_symlink_etc:
  file.symlink:
    - name: /etc/mailman.cfg
    - target: /etc/mailman/mailman.cfg

mailman_webui_manage_file:
  file.managed:
    - name: /var/lib/mailman_webui/manage.py
    - source: salt://profile/mailman3/files/manage.py
    - require:
      - file: mailman_webui_dir
    - require_in:
      - service: mailman_service
    - watch_in:
      - module: mailman_restart

mailman_webui_settings_file:
  file.managed:
    - name: /var/lib/mailman_webui/settings.py
    - source: salt://profile/mailman3/files/settings.py
    - template: jinja
    - require:
      - file: mailman_webui_dir
    - require_in:
      - service: mailman_webui_service
    - watch_in:
      - module: mailman_webui_restart

mailman_webui_urls_file:
  file.managed:
    - name: /var/lib/mailman_webui/urls.py
    - source: salt://profile/mailman3/files/urls.py
    - require:
      - file: mailman_webui_dir
    - require_in:
      - service: mailman_webui_service
    - watch_in:
      - module: mailman_webui_restart

mailman_webui_wsgi_file:
  file.managed:
    - name: /var/lib/mailman_webui/wsgi.py
    - source: salt://profile/mailman3/files/wsgi.py
    - require:
      - file: mailman_webui_dir
    - require_in:
      - service: mailman_webui_service
    - watch_in:
      - module: mailman_webui_restart

mailman_disable_signup:
  file.managed:
    - name: /var/lib/mailman_webui/django_fedora_nosignup.py
    - source: salt://profile/mailman3/files/django_fedora_nosignup.py
    - require:
      - file: mailman_webui_dir

mailman_uwsgi_conf:
  file.managed:
    - name: /etc/mailman/uwsgi.ini
    - source: salt://profile/mailman3/files/uwsgi.ini
    - require:
      - file: mailman_conf_dir
    - require_in:
      - service: mailman_webui_service
    - watch_in:
      - module: mailman_webui_restart

{% set logfiles = ['uwsgi', 'uwsgi-cron', 'uwsgi-error', 'uwsgi-qcluster'] %}

{% for logfile in logfiles %}
mailman_{{ logfile }}_file:
  file.managed:
    - name: /var/log/mailman/{{ logfile }}.log
    - user: mailman
    - replace: False
    - require:
      - file: mailman_log_dir
    - require_in:
      - service: mailman_service
    - watch_in:
      - module: mailman_restart
{% endfor %}

mailman_hyperkitty_conf:
  file.managed:
    - name: /etc/mailman/hyperkitty.cfg
    - source: salt://profile/mailman3/files/hyperkitty.cfg
    - template: jinja
    - require:
      - file: mailman_conf_dir
    - require_in:
      - service: mailman_webui_service
    - watch_in:
      - module: mailman_webui_restart

/var/lib/mailman_webui/secret.txt:
  file.managed:
    - contents_pillar: profile:mailman3:secret_txt
    - mode: 640
    - user: mailman
    - group: mailman

mailman_nginx_conf:
  file.managed:
    - name: /etc/nginx/conf.d/lists.opensuse.org.conf
    - source: salt://profile/mailman3/files/nginx.conf
    - require_in:
      - service: mailman_webui_service
    - watch_in:
      - module: mailman_webui_restart
