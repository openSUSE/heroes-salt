/etc/php7/fpm/php.ini:
  file.managed:
    - contents:
      - memory_limit = 192M
      - opcache.enable=1
      - opcache.interned_strings_buffer=8
      - opcache.max_accelerated_files=10000
      - opcache.memory_consumption=128
      - opcache.save_comments=1
      - opcache.revalidate_freq=1

/etc/php7/fpm/php-fpm.conf:
  file.managed:
    - contents:
      - pid = run/php-fpm.pid
      - error_log = syslog
      - syslog.ident = fpm
      - log_level = notice
      - include=/etc/php7/fpm/php-fpm.d/*.conf

/etc/php7/fpm/php-fpm.d/forums.conf:
  file.managed:
    - source: salt://profile/vbulletin/files/fpm-listener.conf
    - template: jinja
    - context:
        name: forums
        user: nginx

php-fpm:
  service.running:
    - enable: True
    - watch:
      - file: /etc/php7/fpm/*

