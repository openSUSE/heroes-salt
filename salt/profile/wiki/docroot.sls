#
# create the DocumentRoot and the directories and symlinks needed for all wikis
#

{% set mediawiki_1_27 = salt['pillar.get']('mediawiki_1_27:wikis', {}) %}

# create /srv/www/$lang.opensuse.org and all symlinks and directories needed in it
{% for wiki, data in mediawiki_1_27.items() %}

/srv/www/{{ wiki }}.opensuse.org/public:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set mediawiki_1_27_wwwrun_dirs = [ 'cache', 'tmp', 'public/images' ] %}

{% for dir in mediawiki_1_27_wwwrun_dirs %}
/srv/www/{{ wiki }}.opensuse.org/{{ dir }}:
  file.directory:
    - user: wwwrun
    - group: root
    - mode: 755
    - makedirs: True
{%endfor%}

/srv/www/{{ wiki }}.opensuse.org/public/mediawiki_src:
  file.symlink:
    - target: /usr/share/mediawiki_1_27/

{% set mediawiki_1_27_symlinks = [ 'api.php', 'autoload.php', 'extensions', 'img_auth.php', 'includes', 'index.php', 'languages', 'load.php', 'maintenance',
                                   'opensearch_desc.php', 'resources', 'serialized', 'skins', 'thumb_handler.php', 'thumb.php', 'vendor', ] %}
{% for symlink in mediawiki_1_27_symlinks %}
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
      mysql_server: {{ pillar['mediawiki_1_27']['mysql_server'] }}
      elasticsearch_server: {{ pillar['mediawiki_1_27']['elasticsearch_server'] }}
      wiki: {{ wiki }}
    - source: salt://profile/wiki/files/wiki_settings.php
    - template: jinja

{% if data.get('robots') %}
/srv/www//{{ wiki }}.opensuse.org/public/robots.txt:
  file.managed:
    - source: salt://profile/wiki/files/{{ data.robots }}
{% endif %}

{%endfor%}

# SQL commands to migrate old hit counter data
# can be removed after updating all wikis to 1.27
/srv/www/migrate-wiki-counter.sql:
  file.managed:
    - source: salt://profile/wiki/files/migrate-wiki-counter.sql
