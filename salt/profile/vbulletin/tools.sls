# NB: these tools should not be enabled in production

{% set tools = salt['pillar.get']('vbulletin:tools', False) %}

/srv/www/vhosts/forums/htdocs/core/install:
{% if tools %}
  file.copy:
    - source: /srv/www/vhosts/forums/upload/core/install
    - preserve: True
    - user: root
    - group: nginx
    - mode: 644
{% else %}
  file.absent
{% endif %}

/srv/www/vhosts/forums/htdocs/vb_test.php:
{% if tools %}
  file.managed:
    - source: salt://profile/vbulletin/files/vb_test.php
{% else %}
  file.absent
{% endif %}

/srv/www/vhosts/forums/htdocs/info.php:
{% if tools %}
  file.managed:
    - contents: "<?php phpinfo(); ?>"
{% else %}
  file.absent
{% endif %}

/srv/www/vhosts/forums/db-tweak.sql:
{% if tools %}
  file.managed:
    - source: salt://profile/vbulletin/files/db-tweak.sql
    - template: jinja
    - defaults:
        dbname: {{ pillar.vbulletin.config.Database.dbname }}
        host: {{ pillar.vbulletin.config.MasterServer.servername }}
        username: {{ pillar.vbulletin.config.MasterServer.username }}
        password: {{ pillar.vbulletin.config.MasterServer.password }}
        bburl: {{ grains.weburls[0] ~ '/forum' }}
        frontendurl: {{ grains.weburls[0] }}
{% else %}
  file.absent
{% endif %}


