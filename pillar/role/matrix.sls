include:
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.matrix
  {% endif %}
  - role.common.nginx

profile:
  matrix:
    database_host: localhost
    database_name: matrix
    database_user: matrix
    appservices:
      discord:
        repo: https://github.com/Half-Shot/matrix-appservice-discord.git
        client_id: 672058964707377152
        appservice_id: 330d1b6dcdf6a2217454f8227d2a960030d341a8baca5fa5c40f4081b6f40acd
        build: True
        script: /usr/bin/node build/src/discordas.js -c config.yaml -f discord-registration.yaml -p 9001
      webhook:
        repo: https://github.com/turt2live/matrix-appservice-webhooks
        appservice_id: f4de7550133374c703c4cd64c5898cf1b82b65d4a5c2aca93863ee1fb859df91
        build: False
        script: /usr/bin/node index.js -c config.yaml -f webhook-registration.yaml -p 9002
      irc:
        repo: https://github.com/matrix-org/matrix-appservice-irc
        appservice_id: 1deb544b666b3aba1d9d49d3d4785eeb2fb2befa24e0743c91e6290866003c33
        build: True
        script: /usr/bin/node app.js -c config.yaml -f irc-registration.yaml -p 9003
    telegram:
      appservice_id: oepzkscngbyqvopzn773ns7whfxyfslgjhy7mumy7syurqp3f4kvb4sgufz9nfsw
      api_id: 1331253

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
                    - text/xml
                    - text/x-js
                    - application/json
                    - text/css
                    - application/x-javascript
                    - application/javascript
                - location /:
                    - index:
                        - index.html
                        - index.htm
                - location ~* \.(?:ttf|otf|eot|woff)$:
                    - add_header: Access-Control-Allow-Origin "*"
                - access_log: /var/log/nginx/chat.access.log combined
                - error_log: /var/log/nginx/chat.error.log
          enabled: True
        dimension.opensuse.org:
          config:
            - server:
                - server_name: dimension.opensuse.org
                - listen:
                    - 80
                - location /:
                    - proxy_set_header: X-Forwarded-For $remote_addr
                    - proxy_pass: http://localhost:8184
          enabled: True
        matrix.opensuse.org:
          config:
            - server:
                - server_name: matrix.opensuse.org
                - listen:
                    - 80
                - location /_matrix:
                    - proxy_set_header: X-Forwarded-For $remote_addr
                    - proxy_pass: http://localhost:8008
          enabled: True
        webhook.opensuse.org:
          config:
            - server:
                - server_name: webhook.opensuse.org
                - listen:
                    - 80
                - location /:
                    - proxy_set_header: X-Forwarded-For $remote_addr
                    - proxy_pass: http://localhost:9002
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
