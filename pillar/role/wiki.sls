include:
  - role.common.wiki

apparmor:
  profiles:
    httpd2-prefork:
      source: salt://profile/wiki/files/httpd2-prefork.apparmor
      template: jinja
    memcached:
      source: salt://profile/wiki/files/memcached.apparmor
    pygmentize:
      source: salt://profile/wiki/files/pygmentize.apparmor

# list of wikis running MediaWiki 1.27 (this will allow us to migrate to a new version one by one later)
mediawiki_1_27:
  elasticsearch_server: water.infra.opensuse.org
  mysql_server: mysql.infra.opensuse.org
  wikis:
    # availale options:
      # bento_lang: en
      # dbmysql5: False  # only needed for old-en and old-de, defaults to True
      # dbpass: not_in_salt_yet
      # lang: en
      # skin: Chameleon  # defaults to 'bento' if not set. Explicitely setting it to 'bento' will load 'Chameleon' as alternative/user-selectable skin
      # readonly_msg: 'This wiki is in read-only mode for maintenance!'
      # robots: robots-disallow.txt  # filename in salt/profile/wiki/files/, defaults to 'robots.txt'
      # site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    cn:
      dbpass: not_in_salt_yet
    cs:
      dbpass: not_in_salt_yet
    de:
      dbpass: not_in_salt_yet
    el:
      dbpass: not_in_salt_yet
    en:
      dbpass: not_in_salt_yet
    en-test:
      bento_lang: en
      dbpass: not_in_salt_yet
      lang: en
      skin: Chameleon
      robots: robots-disallow.txt
      site_notice: 'This is a test wiki. You are more than welcome to do test edits, but please keep in mind that all changes will be lost when we import a newer database dump.'
    es:
      dbpass: not_in_salt_yet
    fr:
      dbpass: not_in_salt_yet
    hu:
      dbpass: not_in_salt_yet
    it:
      dbpass: not_in_salt_yet
    ja:
      dbpass: not_in_salt_yet
    languages:
      dbpass: not_in_salt_yet
    nl:
      dbpass: not_in_salt_yet
    old-de:
      bento_lang: de
      dbpass: not_in_salt_yet
      dbmysql5: False
      lang: de
      readonly_msg: 'Dieses Wiki ist ein Archiv und kann nicht bearbeitet werden.'
      robots: robots-disallow.txt
      site_notice: 'Dieses Wiki ist ein Archiv (Stand: 2011) des alten openSUSE-Wikis. Das aktuelle openSUSE-Wiki finden Sie unter [https://de.opensuse.org de.opensuse.org].'
    old-en:
      bento_lang: en
      dbmysql5: False
      dbpass: not_in_salt_yet
      lang: en
      readonly_msg: 'This wiki is an archive and cannot be edited.'
      robots: robots-disallow.txt
      site_notice: 'This wiki is an archive (from 2011) of the old openSUSE wiki. You can find the up to date openSUSE wiki at [https://en.opensuse.org en.opensuse.org].'
    pl:
      dbpass: not_in_salt_yet
    pt:
      dbpass: not_in_salt_yet
    ru:
      dbpass: not_in_salt_yet
    sv:
      dbpass: not_in_salt_yet
    tr:
      dbpass: not_in_salt_yet
    zh:
      dbpass: not_in_salt_yet
    zh-tw:
      bento_lang: zh_TW
      dbpass: not_in_salt_yet
      lang: zh_TW

# special cases for bento_lang:
# cz    -> bento_lang cs
# pt-br -> bento_lang pt_BR
# zh_tw -> bento_lang zh_TW
# full bento_lang list: https://github.com/openSUSE/opensuse-themes/tree/master/bento/js/l10n

profile:
  monitoring:
    checks:
      check_memcached_bytes: '/usr/lib/nagios/plugins/check_memcached.pl -H 127.0.0.1 -p 11211 -a -f  --bytes=400000000,500000000'
      check_memcached_total_items: '/usr/lib/nagios/plugins/check_memcached.pl -H 127.0.0.1 -p 11211 -a -f  --total_items=ZERO:OK'

zypper:
  packages:
    apache2: {}
    apache2-mod_apparmor: {}
    apache2-prefork: {}
    # needed for deploying en-test without going through packaging
    git: {}
    mediawiki_1_27-openSUSE: {}
    mariadb-client: {}
    check_mk-agent-apache_status: {}
    # needed for migration to unpack tarballs
    tar: {}
