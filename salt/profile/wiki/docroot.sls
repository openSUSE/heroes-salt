#
# create the DocumentRoot and the directories and symlinks needed for all wikis
#

{% set mediawiki = salt['pillar.get']('mediawiki:wikis', {}) %}

# create /srv/www/$lang.opensuse.org and all symlinks and directories needed in it
{% for wiki, data in mediawiki.items() %}

{% set version = data.get('version', salt['pillar.get']('mediawiki:default_version')) %}

/srv/www/{{ wiki }}.opensuse.org/public:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set mediawiki_wwwrun_dirs = [ 'cache', 'tmp', 'public/images' ] %}

{% for dir in mediawiki_wwwrun_dirs %}
/srv/www/{{ wiki }}.opensuse.org/{{ dir }}:
  file.directory:
    - user: wwwrun
    - group: root
    - mode: 755
    - makedirs: True
{%endfor%}

/srv/www/{{ wiki }}.opensuse.org/public/mediawiki_src:
  file.symlink:
    - target: /usr/share/mediawiki_{{ version }}/
    # Note for en-test:
    # /usr/share/mediawiki_1_*-git/ is `git clone https://github.com/openSUSE/wiki/`
    # + symlinks to /usr/share/mediawiki_1_*/ for everything not in the git repo
    # (git clone and creating these symlinks needs to be done manually!)

{% set mediawiki_symlinks = [ 'api.php', 'autoload.php', 'extensions', 'img_auth.php', 'includes', 'index.php', 'languages', 'load.php', 'maintenance',
                                   'opensearch_desc.php', 'resources', 'serialized', 'skins', 'thumb_handler.php', 'thumb.php', 'vendor', ] %}
{% for symlink in mediawiki_symlinks %}
/srv/www/{{ wiki }}.opensuse.org/public/{{ symlink }}:
  file.symlink:
    - target: mediawiki_src/{{ symlink }}
{%endfor%}

/srv/www//{{ wiki }}.opensuse.org/public/LocalSettings.php:
  file.managed:
    - source: salt://profile/wiki/files/LocalSettings.php

/srv/www//{{ wiki }}.opensuse.org/wiki_settings.php:
  file.managed:
    - context:
      data: {{ data }}
      mysql_server: {{ pillar['mediawiki']['mysql_server'] }}
      elasticsearch_server: {{ pillar['mediawiki']['elasticsearch_server'] }}
      wiki: {{ wiki }}
    - source: salt://profile/wiki/files/wiki_settings.php
    - template: jinja

/srv/www//{{ wiki }}.opensuse.org/public/robots.txt:
  file.managed:
    - source: salt://profile/wiki/files/{{ data.get('robots', 'robots.txt') }}

{%endfor%}

# SQL commands to migrate old hit counter data
# can be removed after updating all wikis to 1.27
/srv/www/migrate-wiki-counter.sql:
  file.managed:
    - source: salt://profile/wiki/files/migrate-wiki-counter.sql
