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
    en:
      dbpass: not_in_salt_yet
#      readonly_msg: 'This wiki is in read-only mode for maintenance!'
#      site_notice: 'Welcome to the updated openSUSE wiki! If you notice any issues, please send a mail to admin [at] opensuse.org'
    en-test:
      alias: wikimove.opensuse.org
      bento_lang: en
      dbpass: not_in_salt_yet
      lang: en
      site_notice: 'This is a test wiki. You are more than welcome to do test edits, but please keep in mind that all changes will be lost when we import a newer database dump.'

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
