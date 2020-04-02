{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.matrix
{% endif %}

profile:
  matrix:
    database_host: postgresql.infra.opensuse.org
    database_name: matrix
    database_user: matrix
    appservices:
      discord:
        repo: https://github.com/Half-Shot/matrix-appservice-discord.git
        port: 9001
        client_id: 672058964707377152
        appservice_id: 330d1b6dcdf6a2217454f8227d2a960030d341a8baca5fa5c40f4081b6f40acd
      webhook:
        repo: https://github.com/turt2live/matrix-appservice-webhooks
        port: 9002
        appservice_id: f4de7550133374c703c4cd64c5898cf1b82b65d4a5c2aca93863ee1fb859df91
      irc:
        repo: https://github.com/matrix-org/matrix-appservice-irc
        port: 9003
        appservice_id: 1deb544b666b3aba1d9d49d3d4785eeb2fb2befa24e0743c91e6290866003c33
    telegram:
      appservice_id: oepzkscngbyqvopzn773ns7whfxyfslgjhy7mumy7syurqp3f4kvb4sgufz9nfsw
      api_id: 1331253

include:
  - role.common.nginx

nginx:
  ng:
    servers:
      managed:
        chat.opensuse.org.conf:
          config:
            - server:
                - server_name: chat.opensuse.org
                - listen:
                    - 80
                    - default_server
                - root: /var/www/riot-web
                - gzip_vary: 'on'
                - gzip_min_length: 1000
                - gzip_comp_level: 5
                - gzip_types:
                    - text/plain
                    - text/xml text/x-js
                    - application/json
                    - text/css
                    - application/x-javascript
                    - application/javascript
                - expires: $expires
                - location /:
                    - index:
                        - index.html
                        - index.htm
                - location ~* \.(?:ttf|otf|eot|woff)$:
                    - add_header: Access-Control-Allow-Origin "*"
                - access_log: /var/log/nginx/chat.access.log combined
                - error_log: /var/log/nginx/chat.error.log
            - server:
                - server_name: dimension.opensuse.org
                - listen:
                    - 80
                - root: /var/www/html
                - index: index.html
                - location /:
                    - proxy_set_header X-Forwarded-For: $proxy_add_x_forwarded_for
                    - proxy_pass: http://localhost:8184
          enabled: True

sudoers:
  included_files:
    /etc/sudoers.d/group_matrix-admins:
      groups:
        matrix-admins:
          - 'ALL=(ALL) ALL'

apparmor:
  profiles:
    matrix-synapse:
      source: salt://profile/matrix/files/matrix-synapse.apparmor

zypper:
  repositories:
    openSUSE:infrastructure:matrix:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/matrix/openSUSE_Leap_$releasever/
      priority: 100
      refresh: True
