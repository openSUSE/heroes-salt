# NB: do not enable these tools in production

{% set tools = salt['pillar.get']('vbulletin:tools', False) %}

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
        host: {{ pillar.vbulletin.config.MasterServer.servername }}
        username: {{ pillar.vbulletin.config.MasterServer.username }}
        password: {{ pillar.vbulletin.config.MasterServer.password }}
        bburl: {{ grains.weburls[0] ~ '/forum' }}
        frontendurl: {{ grains.weburls[0] }}
{% else %}
  file.absent
{% endif %}


