profile_wiki_php_apparmor:
  file.managed:
    - name: /etc/apparmor.d/php-fpm.d/wiki
    - source: salt://profile/wiki/files/php-fpm/apparmor.jinja
    - template: jinja

profile_wiki_php_pool:
  file.managed:
    - names:
        - /etc/php7/fpm/php-fpm.conf:
            - contents:
                - {{ pillar['managed_by_salt_ini'] | yaml_encode }}
                - include=/etc/php7/fpm/php-fpm.d/wiki.conf
        - /etc/php7/fpm/php-fpm.d/wiki.conf:
            - source: salt://profile/wiki/files/php-fpm/php-fpm.jinja
            - template: jinja

profile_wiki_php_apparmor_load:
  cmd.run:
    - name: apparmor_parser -r /etc/apparmor.d/php-fpm
    - onchanges:
        - file: profile_wiki_php_apparmor

profile_wiki_php_pool_load:
  service.running:
    - name: php-fpm
    - enable: true
    - reload: true
    - watch:
        - file: profile_wiki_php_pool
