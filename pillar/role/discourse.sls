include:
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.discourse
  {% endif %}
  - role.common.nginx

profile:
  postfix:
    maincf:
      inet_interfaces: all
      smtputf8_enable: 'no'
      compatibility_level: 2
      export_environment: 'TZ LANG'
      append_dot_mydomain: 'no'
      mydestination: localhost
      mynetworks: '127.0.0.0/8 [::1]/128 [fe80::]/64'
      transport_maps: lmdb:/etc/postfix/transport
      smtpd_recipient_restrictions: permit_mynetworks, check_policy_service unix:private/policy
    mastercf:
      discourse: unix - n n - - pipe user=nobody:nogroup argv=/usr/bin/receive-mail ${recipient}
      policy: unix - n n - - spawn user=nobody argv=/usr/bin/discourse-smtp-fast-rejection
    aliases:
      discourse: root
    # We need to set up transport map with `$domain discourse:` line for every domain
  discourse:
    database_user: discourse
    database_name: discourse
    database_host: postgresql.infra.opensuse.org
    hostname: forums.opensuse.org
    smtp_domain: forums.opensuse.org
    # secret_key, maxmind and db password live in secrets/role/discourse.sls

# nginx configuration should be kept in sync with the packaged
#   /srv/www/vhosts/discourse/config/nginx.sample.conf
# which in return is in sync with
#  https://raw.githubusercontent.com/discourse/discourse/refs/heads/main/config/nginx.sample.conf
# however, we maintain a few customizations

{%- macro commonproxylocationheaders(accel_redirect_downloads=false, inside=true) -%}
  {%- if accel_redirect_downloads %}
    {%- set sendfile_type = 'X-Accel-Redirect' %}
    {%- set accel_mapping = '$public/=/downloads/' %}
  {%- else %}
    {%- set sendfile_type = '""' %}
    {%- set accel_mapping = '""' %}
  {%- endif %}
  {%- for header in [
          'Host $http_host',
          'X-Real-IP $remote_addr',
          'X-Request-Start "t=${msec}"',
          'X-Forwarded-For $proxy_add_x_forwarded_for',
          'X-Forwarded-Proto $thescheme',
          'X-Sendfile-Type ' ~ sendfile_type,
          'X-Accel-Mapping ' ~ accel_mapping,
    ] %}
                  {{ '    ' if inside else '' }}- proxy_set_header: {{ header }}
  {%- endfor %}
{%- endmacro -%}
{%- macro commonproxylocation(accel_redirect_downloads=false, inside=true) -%}
                  {{ commonproxylocationheaders(accel_redirect_downloads, inside) }}
                  {{ '    ' if inside else '' }}- proxy_pass: http://discourse
                  {{ '    ' if inside else '' }}- break
{%- endmacro -%}

nginx:
  server:
    config:
      load_module:
        - /usr/lib64/nginx/modules/ngx_http_brotli_static_module.so
        - /usr/lib64/nginx/modules/ngx_http_brotli_filter_module.so
  servers:
    managed:
      forums.opensuse.org.conf:
        config:
          - upstream discourse:
              - server: 'unix:/srv/www/vhosts/discourse/tmp/sockets/puma.sock'
          - types:
              - text/csv: csv
              - application/wasm: wasm
          - proxy_cache_path: /var/lib/nginx/cache/ inactive=1440m levels=1:2 keys_zone=one:10m max_size=600m
          - proxy_buffer_size: 32k
          - proxy_buffers: 4 32k
          - large_client_header_buffers: 4 32k
          - map $http_x_forwarded_proto $thescheme:
              - default: $scheme
              - https: https
          - log_format: >-
              log_discourse
              '[$time_local] "$http_host" $remote_addr "$request" "$http_user_agent" "$sent_http_x_discourse_route"
              $status $bytes_sent "$http_referer" $upstream_response_time $request_time "$upstream_http_x_discourse_username"
              "$upstream_http_x_discourse_trackview" "$upstream_http_x_queue_time" "$upstream_http_x_redis_calls"
              "$upstream_http_x_redis_time" "$upstream_http_x_sql_calls" "$upstream_http_x_sql_time"'
          - geo $bypass_cache:
              - default: 0
              - 127.0.0.1: 1
              - '::1': 1
          - server:
              - server_name: forums.opensuse.org
              - server_tokens: "off"
              - listen: '[::]:80 default_server'
              - access_log: /var/log/nginx/discourse.access.log.gz log_discourse flush=2m gzip=8
              - gzip: "on"
              - gzip_vary: "on"
              - gzip_min_length: 1000
              - gzip_comp_level: 5
              - gzip_types: application/json text/css text/javascript application/x-javascript application/javascript image/svg+xml application/wasm
              - gzip_proxied: any
              - sendfile: "on"
              - keepalive_timeout: 65
              - client_max_body_size: 10m
              - set: $public /srv/www/vhosts/discourse/public
              - etag: "off"
              - location ^~ /backups/:
                  - internal: ''
              - location /favicon.ico:
                  - return: 204
                  - access_log: "off"
                  - log_not_found: "off"
              - location /:
                  - root: $public
                  - add_header: ETag ""
                  - location ~ ^/uploads/short-url/:
                      {{ commonproxylocation() }}
                  - location ~ ^/(secure-media-uploads/|secure-uploads)/:
                      {{ commonproxylocation() }}
                  - location ~* (fonts|assets|plugins|uploads)/.*\.(eot|ttf|woff|woff2|ico|otf)$:
                      - expires: 1y
                      - add_header: Cache-Control public,immutable
                      - add_header: Access-Control-Allow-Origin *
                  - location = /srv/status:
                      - access_log: "off"
                      - log_not_found: "off"
                      {{ commonproxylocation() }}
                  - location ~ ^/javascripts/:
                      - expires: 1d
                      - add_header: Cache-Control public,immutable
                      - add_header: Access-Control-Allow-Origin *
                  - location ~ ^/assets/(?<asset_path>.+)$:
                      - expires: 1y
                      {%- if not grains['host'].startswith('runner-') %} {#- ugly, but required for tests due to the modules being commented out above #}
                      - brotli_static: "on"
                      {%- endif %}
                      - gzip_static: "on"
                      - add_header: Cache-Control public,immutable
                      - break
                  - location ~ ^/plugins/:
                      - expires: 1y
                      - add_header: Cache-Control public,immutable
                      - add_header: Access-Control-Allow-Origin *
                  - location ~ /images/emoji/:
                      - expires: 1y
                      - add_header: Cache-Control public,immutable
                      - add_header: Access-Control-Allow-Origin *
                  - location ~ ^/uploads/:
                      {{ commonproxylocationheaders(accel_redirect_downloads=true) }}
                      - expires: 1y
                      - add_header: Cache-Control public,immutable
                      - location ~ /stylesheet-cache/:
                          - add_header: Access-Control-Allow-Origin *
                          - try_files: $uri =404
                      - location ~* \.(gif|png|jpg|jpeg|bmp|tif|tiff|ico|webp)$:
                          - add_header: Access-Control-Allow-Origin *
                          - try_files: $uri =404
                      # Intentionally left blank
                      # https://github.com/discourse/discourse/commit/31e31ef44973dc4daaee2f010d71588ea5873b53#diff-e79d9fceaf4e304b8b83b0aa41729344b3266e90105e574b1a8cb26413c307e1
                      - location ~* \.(svg)$:
                          -
                      - location ~ /_?optimized/:
                          - add_header: Access-Control-Allow-Origin *
                          - try_files: $uri =404
                      - proxy_pass: http://discourse
                      - break
                  - location ~ ^/admin/backups/:
                      {{ commonproxylocation(accel_redirect_downloads=true) }}
                  - location ~ ^/(svg-sprite/|letter_avatar/|letter_avatar_proxy/|user_avatar|highlight-js|stylesheets|theme-javascripts|favicon/proxied|service-worker):  # noqa 204
                      - access_log: "off"
                      {{ commonproxylocationheaders() }}
                      - proxy_ignore_headers: "Set-Cookie"
                      - proxy_hide_header: "Set-Cookie"
                      - proxy_hide_header: "X-Discourse-Username"
                      - proxy_hide_header: "X-Runtime"
                      - proxy_cache: one
                      - proxy_cache_key: "$scheme,$host,$request_uri"
                      - proxy_cache_valid: 200 301 302 7d
                      - proxy_cache_bypass: $bypass_cache
                      - proxy_pass: http://discourse
                      - break
                  - location /message-bus/:
                      - access_log: "off"
                      {{ commonproxylocationheaders() }}
                      - proxy_http_version: 1.1
                      - proxy_buffering: "off"
                      - proxy_pass: http://discourse
                      - break
                  - try_files: $uri @discourse
              - location /downloads/:
                  - internal: ''
                  - alias: $public/
              - location @discourse:
                  {{ commonproxylocation(inside=false) }}
              - location /showthread.php/:
                  - rewrite: '^/showthread.php/([0-9]*) /thread/$1 permanent'
              - location /content.php/:
                  - rewrite: '^/content.php/([0-9]*) /article/$1 permanent'
              - location /entry.php/:
                  - rewrite: '^/entry.php/([0-9]*) /blog/$1 permanent'
              - if ($arg_signup = true):
                  - return: 301 https://idp-portal.suse.com/univention/self-service/#page=createaccount
        enabled: True

zypper:
  repositories:
    darix:apps:
      baseurl: http://$mirror_int/repositories/home:/darix:/apps/openSUSE_Tumbleweed/
      priority: 100
      refresh: True
    openSUSE:infrastructure:discourse:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/discourse/openSUSE_Tumbleweed/
      priority: 100
      refresh: True
