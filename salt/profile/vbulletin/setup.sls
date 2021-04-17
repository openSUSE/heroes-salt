/srv/www/vhosts/forums:
  file.directory:
    - user: root
    - group: nginx
    - dir_mode: 750
    - makedirs: True
  archive.extracted:
    - source: /root/vb5_connect.zip
    - keep_source: False
    - enforce_toplevel: False
    - trim_output: True

/srv/www/vhosts/forums/htdocs:
  file.copy:
    - source: /srv/www/vhosts/forums/upload
    - preserve: True
    - user: root
    - group: nginx
    - mode: 644

/srv/www/vhosts/forums/htdocs/.htaccess:
  file.rename:
    - source: /srv/www/vhosts/forums/htdocs/htaccess.txt

/srv/www/vhosts/forums/htdocs/config.php:
  file.rename:
    - source: /srv/www/vhosts/forums/htdocs/config.php.bkp

/srv/www/vhosts/forums/htdocs/core/includes/config.php:
  file.rename:
    - source: /srv/www/vhosts/forums/htdocs/core/includes/config.php.new

{% for key1, values in pillar.vbulletin.config.items() %}
{% for key2, value in values.items() %}

configure vBulletin {{key1}}-{{key2}}:
  file.line:
    - name: /srv/www/vhosts/forums/htdocs/core/includes/config.php
    - match: "^(// )?\\$config\\['{{key1}}']\\['{{key2}}']"
    - content: "$config['{{key1}}']['{{key2}}'] = '{{value}}';"
    - mode: replace

{% endfor %}
{% endfor %}

/srv/www/vhosts/forums/htdocs/core/includes/md5_sums_vbulletin.php:
  file.managed:
    - mode: 444
    - create: no
    - replace: no

/srv/www/vhosts/forums/htdocs/core/cache/css:
  file.directory:
    - user: nginx
    - recurse:
      - user

/srv/www/vhosts/forums/sitemap:
  file.directory:
    - user: nginx

