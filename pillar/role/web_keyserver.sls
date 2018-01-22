{% set host = salt['grains.get']('host') %}
{% set ip4_private = salt['grains.get']('ipv4_interfaces:private[0]') %}

include:
  - role.common.nginx

nginx:
  ng:
    server:
      config:
        http:
          client_max_body_size: 8m
          gzip_static: 'on'
          gzip_min_length: 1000
          gzip_proxied:
            - expired
            - no-cache
            - no-store
            - private
            - auth
          gzip_types:
            - text/plain
            - text/css
            - application/xml
            - application/x-javascript
        worker_processes: 4
    servers:
      managed:
        keyserver.opensuse.org.conf:
          config:
            - server:
                - listen:
                    - 80
                    - default_server
                - listen:
                    - {{ ip4_private }}:11371
                    - default_server
                - server_name: keyserver.opensuse.org
                - server_name: {{ host }}.opensuse.org
                - server_name: '*.sks-keyservers.net'
                - server_name: '*.pool.sks-keyservers.net'
                - server_name: pgp.mit.edu
                - server_name: keys.gnupg.net
                - root: /srv/www/htdocs
                - rewrite: ^/stats /pks/lookup?op=stats
                - rewrite: ^/s/(.*) /pks/lookup?search=$1
                - rewrite: ^/search/(.*) /pks/lookup?search=$1
                - rewrite: ^/g/(.*) /pks/lookup?op=get&search=$1
                - rewrite: ^/get/(.*) /pks/lookup?op=get&search=$1
                - rewrite: ^/hashquery /pks/hashquery
                - rewrite: ^/hashquery/(.*) /pks/hashquery/$1
                - rewrite: ^/d/(.*) /pks/lookup?op=get&options=mr&search=$1
                - rewrite: ^/download/(.*) /pks/lookup?op=get&options=mr&search=$1
                - expires: 1y
                - add_header: Pragma public
                - add_header: Cache-Control "public"
                - location /check.txt:
                    - root: /srv/www/htdocs
                    - access_log: 'off'
                - location /:
                    - root: /srv/www/htdocs
                    - index:
                        - index.html
                        - index.htm
                - location /pks:
                    - proxy_pass: http://127.0.0.1:11371
                    - proxy_pass_header: Server
                    - add_header: Via "1.1 {{ host }}.opensuse.org:11371"
                    - proxy_ignore_client_abort: 'on'
                    - client_max_body_size: 8m
                - error_page: 500 502 503 504 /50x.html
                - location = /50x.html:
                    - root: /srv/www/htdocs
          enabled: True
