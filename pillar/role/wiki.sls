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
      # alias: wikimove.opensuse.org
      # bento_lang: en
      # dbmysql5: False  # only needed for old-en and old-de, defaults to True
      # dbpass: not_in_salt_yet
      # lang: en
      # readonly_msg: 'This wiki is in read-only mode for maintenance!'
      # site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    cn:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    cs:
      alias: cz.opensuse.org
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    de:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    el:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    en:
      dbpass: not_in_salt_yet
      site_notice: 'The english openSUSE wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    en-test:
      alias: wikimove.opensuse.org
      bento_lang: en
      dbpass: not_in_salt_yet
      lang: en
      site_notice: 'This is a test wiki. You are more than welcome to do test edits, but please keep in mind that all changes will be lost when we import a newer database dump.'
    es:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    fr:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    hu:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    it:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    ja:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    languages:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    nl:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    old-de:
      bento_lang: de
      dbpass: not_in_salt_yet
      dbmysql5: False
      lang: de
      readonly_msg: 'Dieses Wiki ist ein Archiv und kann nicht bearbeitet werden.'
      site_notice: 'Dieses Wiki ist ein Archiv (Stand: 2011) des alten openSUSE-Wikis. Das aktuelle openSUSE-Wiki finden Sie unter [https://de.opensuse.org de.opensuse.org].'
    old-en:
      bento_lang: en
      dbmysql5: False
      dbpass: not_in_salt_yet
      lang: en
      readonly_msg: 'This wiki is an archive and cannot be edited.'
      site_notice: 'This wiki is an archive (from 2011) of the old openSUSE wiki. You can find the up to date openSUSE wiki at [https://en.opensuse.org en.opensuse.org].'
    pl:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    pt:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    ru:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    sv:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    tr:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    zh:
      dbpass: not_in_salt_yet
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    zh-tw:
      alias: zh_tw.opensuse.org
      bento_lang: zh_TW
      dbpass: not_in_salt_yet
      lang: zh_TW
      site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'

# special cases for bento_lang:
# cz    -> bento_lang cs
# pt-br -> bento_lang pt_BR
# zh_tw -> bento_lang zh_TW
# full bento_lang list: https://github.com/openSUSE/opensuse-themes/tree/master/bento/js/l10n

zypper:
  packages:
    apache2: {}
    apache2-mod_apparmor: {}
    apache2-prefork: {}
    mediawiki_1_27-openSUSE: {}
    mariadb-client: {}
    # needed for migration to unpack tarballs
    tar: {}
  repositories:
    openSUSE:infrastructure:wiki:
      baseurl: http://download.opensuse.org/repositories/openSUSE:/infrastructure:/wiki/openSUSE_Leap_{{ grains['osrelease'] }}
      gpgcheck: 0
      priority: 100
      refresh: True
