include:
  - role.common.apache
  - role.common.php-fpm
  - role.common.wiki

{%- set default_wiki_version = '1_37' %}
{%- load_yaml as wikis %}
cn:
  dbpass: not_in_salt_yet
  version: '1_27'
cs:
  dbpass: not_in_salt_yet
  version: '1_27'
de:
  dbpass: not_in_salt_yet
  version: '1_27'
el:
  dbpass: not_in_salt_yet
  version: '1_27'
en:
  dbpass: not_in_salt_yet
en-test:
  bento_lang: en
  dbpass: not_in_salt_yet
  lang: en
  skin: Chameleon
  robots: robots-disallow.txt
  site_notice: >-
    This is a test wiki.
    You are more than welcome to do test edits, but please keep in mind that all changes will be lost when we import a newer database dump.
es:
  dbpass: not_in_salt_yet
  version: '1_27'
fr:
  dbpass: not_in_salt_yet
  version: '1_27'
hu:
  dbpass: not_in_salt_yet
  version: '1_27'
it:
  dbpass: not_in_salt_yet
  version: '1_27'
ja:
  dbpass: not_in_salt_yet
  version: '1_27'
languages:
  dbpass: not_in_salt_yet
  version: '1_27'
nl:
  dbpass: not_in_salt_yet
  version: '1_27'
old-de:
  bento_lang: de
  dbpass: not_in_salt_yet
  dbmysql5: False
  lang: de
  readonly_msg: 'Dieses Wiki ist ein Archiv und kann nicht bearbeitet werden.'
  robots: robots-disallow.txt
  site_notice: >-
    'Dieses Wiki ist ein Archiv (Stand: 2011) des alten openSUSE-Wikis.
    Das aktuelle openSUSE-Wiki finden Sie unter [https://de.opensuse.org de.opensuse.org].'
  version: '1_27'
old-en:
  bento_lang: en
  dbmysql5: False
  dbpass: not_in_salt_yet
  lang: en
  readonly_msg: 'This wiki is an archive and cannot be edited.'
  robots: robots-disallow.txt
  site_notice: >-
    'This wiki is an archive (from 2011) of the old openSUSE wiki.
    You can find the up to date openSUSE wiki at [https://en.opensuse.org en.opensuse.org].'
  version: '1_27'
pl:
  dbpass: not_in_salt_yet
  version: '1_27'
pt:
  dbpass: not_in_salt_yet
  version: '1_27'
ru:
  dbpass: not_in_salt_yet
  version: '1_27'
sv:
  dbpass: not_in_salt_yet
  version: '1_27'
tr:
  dbpass: not_in_salt_yet
  version: '1_27'
zh:
  dbpass: not_in_salt_yet
  version: '1_27'
zh-tw:
  bento_lang: zh_TW
  dbpass: not_in_salt_yet
  lang: zh_TW
  version: '1_27'
{%- endload %}

apache_httpd:
  modules:
    - apparmor
    - proxy
    - proxy_fcgi
  sysconfig:
    apache_serveradmin: admin@opensuse.org
    apache_servertokens: ProductOnly
    apache_serversignature: 'off'
    apache_extended_status: 'on'
  configs:
    index:
      DirectoryIndex: index.php
    log:
      LogFormat: >-
        "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
        combinedproxy
    trace:
      TraceEnable: off
  vhosts:
    {%- for wiki in wikis | sort %}
      {%- set domain = wiki ~ '.opensuse.org' %}
      {%- set pool = 'wiki_' ~ wiki %}
      {%- set root = '/srv/www/' ~ domain ~ '/public' %}
    {{ domain }}:
      AADefaultHatName: vhost_{{ wiki }}
      ServerName: {{ domain }}
      DocumentRoot: {{ root }}
      FilesMatch:
        \.php$:
          SetHandler: '"proxy:unix:/run/php-fpm/{{ pool }}.sock|fcgi://{{ pool }}"'
      RewriteEngine: true
      Directory:
        {{ root }}:
          Require: all granted
          RewriteCond:
            - '%{REQUEST_FILENAME}': '!-f'
            - '%{REQUEST_FILENAME}': '!-d'
          RewriteRule:
            - ^(Index.php/)?(.+)$ index.php?title=$2 [PT,L,QSA]
      CustomLog: >-
        /var/log/apache2/{{ wiki }}-access_log
        combinedproxy
      ErrorLog: /var/log/apache2/{{ wiki }}-error_log
    {%- endfor %}

    {%- set files_domain = 'files.opensuse.org' %}
    {%- set files_root = '/srv/www/' ~ files_domain ~ '/public' %}
    {{ files_domain }}:
      AADefaultHatName: vhost_files
      ServerName: {{ files_domain }}
      DocumentRoot: {{ files_root }}
      Directory:
        {{ files_root }}:
          Require: all granted
      RedirectPermanent:
        {%- for wiki in wikis | sort %}
          {%- if wiki != 'languages' and not 'test' in wiki %}
        /opensuse/{{ wiki }}/: https://{{ wiki }}.opensuse.org/images/
          {%- endif %}
        {%- endfor %}
      CustomLog: >-
        /var/log/apache2/files-access_log
        combinedproxy
      ErrorLog: /var/log/apache2/files-error_log

    localhost:
      ServerName: localhost
      ServerAlias: {{ grains['fqdn'] }}
      DocumentRoot: /srv/www/htdocs
      Directory:
        /srv/www/htdocs:
          Options: None
          AllowOverride: None
          Require: all granted

apparmor:
  local:
    php-fpm:
      - /run/php-fpm/wiki_*.sock rwlk
  profiles:
    httpd2-event:
      source: salt://profile/wiki/files/httpd/apparmor.jinja
      template: jinja
    php-fpm.d/wiki:
      source: salt://profile/wiki/files/php-fpm/apparmor.jinja
      template: jinja
    magick:
      source: salt://profile/wiki/files/magick.apparmor
      template: jinja
    memcached:
      source: salt://profile/wiki/files/memcached.apparmor
    pygmentize:
      source: salt://profile/wiki/files/pygmentize.apparmor

mediawiki:
  default_version: '{{ default_wiki_version }}'
  elasticsearch_server: water4.infra.opensuse.org
  mysql_server: mysql.infra.opensuse.org:3307
  wikis: {{ wikis }}
    # available options:
      # bento_lang: en
      # dbmysql5: False  # only needed for old-en and old-de, defaults to True
      # dbpass: not_in_salt_yet
      # lang: en
      # skin: Chameleon  # defaults to 'Chameleon' if not set. Explicitely setting it to 'bento' will load 'Chameleon' as alternative/user-selectable skin
      # readonly_msg: 'This wiki is in read-only mode for maintenance!'
      # robots: robots-disallow.txt  # filename in salt/profile/wiki/files/, defaults to 'robots.txt'
      # site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'

# special cases for bento_lang:
# cz    -> bento_lang cs
# pt-br -> bento_lang pt_BR
# zh_tw -> bento_lang zh_TW
# full bento_lang list: https://github.com/openSUSE/opensuse-themes/tree/master/bento/js/l10n

php-fpm:
  version: 7
  pools:
    {%- for wiki, wiki_config in wikis | dictsort %}
      {%- set version = wiki_config.get('version', default_wiki_version) %}
    wiki_{{ wiki }}:
      options:
        apparmor_hat: wiki_{{ wiki }}
        user: wwwrun
        group: www
        listen: /run/php-fpm/wiki_{{ wiki }}.sock
        pm: dynamic
      listen:
        owner: wwwrun
        group: www
        mode: '0600'
      env:
        MW_INSTALL_PATH: /srv/www/{{ wiki }}.opensuse.org/public/
        TMP: /srv/www/{{ wiki }}.opensuse.org/tmp/
      php_admin_flag:
        display_errors: false
        log_errors: true
      php_admin_value:
        memory_limit: 16M
        open_basedir: /srv/www/{{ wiki }}.opensuse.org/:/usr/share/mediawiki_{{ version }}:/dev/urandom:/bin/bash
        sendmail_path: /usr/sbin/sendmail -t -i -f noreply+{{ wiki }}-wiki@opensuse.org
        session.save_path: /srv/www/{{ wiki }}.opensuse.org/tmp/
        upload_max_filesize: 10M
        upload_tmp_dir: /srv/www/{{ wiki }}.opensuse.org/tmp/
      {#
        - below calculations are for 24 PHP vhosts (wikis)
      -#}
      pm:
        {#-
          - machine has 11286M total memory
          - keep ~1G for other system processes
          - worker memory_limit is set to 16M above
          - ( 11286-1024 ) / 24 / 16 = ~ 27
          - overprovision (assuming not all wikis are always under full load) by rounding up to 35
        #}
        max_children: 35
        {#-
          - machine has 4 vCPU cores
          - 4 * 2
        #}
        start_servers: 8
        min_spare_servers: 8
        {#-
          - * 2
        #}
        max_spare_servers: 16
    {%- endfor %}

zypper:
  packages:
    # needed for deploying en-test without going through packaging
    git: {}
    ImageMagick: {}
    mediawiki_{{ default_wiki_version }}-openSUSE: {}
    mariadb-client: {}
    # needed for migration to unpack tarballs
    tar: {}
