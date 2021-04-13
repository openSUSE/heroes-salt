include:
  - role.common.nginx
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.web_forum
  {% endif %}

{% set vhost = 'forums' %}
nginx:
  ng:
    servers:
      managed:
        {{vhost}}.conf:
          config:
            - server:
              - listen: 80
              - server_name: forums.opensuse.org
              - root: /srv/www/vhosts/{{vhost}}/htdocs
              - index: index.php index.html
              - access_log: /var/log/nginx/{{vhost}}.access.log combined
              - error_log: /var/log/nginx/{{vhost}}.error.log
              - location = /50x.html:
                - root: /srv/www/htdocs
              - location = /css\.php:
                - rewrite: ^ /core/css.php break
              - location ^~ /install:
                - rewrite: ^/install/ /core/install/ break
              - location /:
                - if (!-f $request_filename):
                  - rewrite: ^/(.*)$ /index.php?routestring=$1 last
              - location ^~ /admincp:
                - if (!-f $request_filename):
                  - rewrite: ^/admincp/?(.*)$ /index.php?routestring=admincp/$1 last
              - location ~ \.php$:
                - if (!-f $request_filename):
                  - rewrite: ^/(.*)$ /index.php?routestring=$1 break
                - fastcgi_split_path_info: ^(.+\.php)(.*)$
                - fastcgi_pass: phpfastcgi
                - fastcgi_index: index.php
                - fastcgi_param: SCRIPT_FILENAME $document_root$fastcgi_script_name
                - include: fastcgi_params
                - fastcgi_param: QUERY_STRING $query_string
                - fastcgi_param: REQUEST_METHOD $request_method
                - fastcgi_param: CONTENT_TYPE $content_type
                - fastcgi_param: CONTENT_LENGTH $content_length
                - fastcgi_intercept_errors: 'on'
                - fastcgi_ignore_client_abort: 'off'
                - fastcgi_connect_timeout: 60
                - fastcgi_send_timeout: 180
                - fastcgi_read_timeout: 180
                - fastcgi_buffers: 256 16k
                - fastcgi_buffer_size: 32k
                - fastcgi_temp_file_write_size: 256k
            - upstream phpfastcgi:
              - server: unix:/run/php-fpm/{{vhost}}.sock
          enabled: True

# configure host-specific parameters for vbulletin in pillar/id/*.sls
vbulletin:
  config:
    Database:
      dbname: webforums2
      technicalemail: admin-auto@opensuse.org
      tableprefix: vb_
    MasterServer:
      servername: 192.168.47.4
      port: 3307
      username: vbulletin
      # password provided as a secret
    Mysqli:
      charset: Latin1
    SpecialUsers:
      canviewadminlog: '1,5'
      canpruneadminlog: '1,5'
      canrunqueries: '1,5'
      undeletableusers: '1'
      superadmins: '1,431,740,783,5442,105475'
    Misc:
      maxwidth: 2592
      maxheight: 1944

zypper:
  packages:
    php7-fpm: {}
    php7-mysql: {}
    php7-gd: {}
    php7-json: {}
    php7-xmlreader: {}
    php7-xmlwriter: {}
    php7-mbstring: {}
    php7-iconv: {}
    php7-imagick: {}
    php7-curl: {}
    php7-ctype: {}
    php7-phar: {}
    php7-opcache: {}
    php7-tokenizer: {}
    php7-zlib: {}

