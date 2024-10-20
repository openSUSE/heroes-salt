include:
  - role.common.wiki

apparmor:
  profiles:
    httpd2-prefork:
      source: salt://profile/wiki/files/httpd2-prefork.apparmor
      template: jinja
    magick:
      source: salt://profile/wiki/files/magick.apparmor
      template: jinja
    memcached:
      source: salt://profile/wiki/files/memcached.apparmor
    pygmentize:
      source: salt://profile/wiki/files/pygmentize.apparmor

# list of wikis running MediaWiki 1.27 (this will allow us to migrate to a new version one by one later)
mediawiki:
  default_version: '1_37'
  elasticsearch_server: water4.infra.opensuse.org
  mysql_server: mysql.infra.opensuse.org:3307
  max_upload_size: 10M # poo#111096
  wikis:
    # availale options:
      # bento_lang: en
      # dbmysql5: False  # only needed for old-en and old-de, defaults to True
      # dbpass: not_in_salt_yet
      # lang: en
      # skin: Chameleon  # defaults to 'Chameleon' if not set. Explicitely setting it to 'bento' will load 'Chameleon' as alternative/user-selectable skin
      # readonly_msg: 'This wiki is in read-only mode for maintenance!'
      # robots: robots-disallow.txt  # filename in salt/profile/wiki/files/, defaults to 'robots.txt'
      # site_notice: 'This wiki has been moved and updated recently. If you encounter any issue, please let us know by mail to admin@opensuse.org.'
    cn:
      dbpass: not_in_salt_yet
      version: '1_27'
    cs:
      dbpass: not_in_salt_yet
      version: '1_27'
    de:
      dbpass: not_in_salt_yet
      # site_notice: '<div class="alert alert-warning">This wiki was updated to MediaWiki 1.37. If you notice any issues, please report them to admin[at]opensuse.org</div>'
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
    # needed for deploying en-test without going through packaging
    git: {}
    ImageMagick: {}
    mediawiki_1_37-openSUSE: {}
    mariadb-client: {}
    # needed for migration to unpack tarballs
    tar: {}
