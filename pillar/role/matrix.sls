include:
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.matrix
  {% endif %}
  - role.common.nginx

profile:
  matrix:
    database_host: 192.168.47.4
    database_name: matrix
    database_user: matrix
    workers:
      generic_worker:
        - rest:
            - ^/_matrix/client/(v2_alpha|r0|v3)/sync$
            - ^/_matrix/client/(api/v1|v2_alpha|r0|v3)/events$
            - ^/_matrix/client/(api/v1|r0|v3)/initialSync$
            - ^/_matrix/client/(api/v1|r0|v3)/rooms/[^/]+/initialSync$
          workers:
            sync1: 8501
        - rest:
            - ^/_matrix/federation/v1/event/
            - ^/_matrix/federation/v1/state/
            - ^/_matrix/federation/v1/state_ids/
            - ^/_matrix/federation/v1/backfill/
            - ^/_matrix/federation/v1/get_missing_events/
            - ^/_matrix/federation/v1/publicRooms
            - ^/_matrix/federation/v1/query/
            - ^/_matrix/federation/v1/make_join/
            - ^/_matrix/federation/v1/make_leave/
            - ^/_matrix/federation/v1/send_join/
            - ^/_matrix/federation/v2/send_join/
            - ^/_matrix/federation/v1/send_leave/
            - ^/_matrix/federation/v2/send_leave/
            - ^/_matrix/federation/v1/invite/
            - ^/_matrix/federation/v2/invite/
            - ^/_matrix/federation/v1/query_auth/
            - ^/_matrix/federation/v1/event_auth/
            - ^/_matrix/federation/v1/exchange_third_party_invite/
            - ^/_matrix/federation/v1/user/devices/
            - ^/_matrix/federation/v1/get_groups_publicised$
            - ^/_matrix/key/v2/query
            - ^/_matrix/federation/unstable/org.matrix.msc2946/spaces/
            - ^/_matrix/federation/(v1|unstable/org.matrix.msc2946)/hierarchy/
            - ^/_matrix/federation/v1/send/
            - ^/_matrix/federation/v1/groups/
          workers:
            federation_requests1: 8511
            federation_requests2: 8512
          upstream_balancing: ip_hash;
        - rest:
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/createRoom$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/publicRooms$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/joined_members$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/context/.*$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/members$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/state$
            - ^/_matrix/client/unstable/org.matrix.msc2946/rooms/.*/spaces$
            - ^/_matrix/client/(v1|unstable/org.matrix.msc2946)/rooms/.*/hierarchy$
            - ^/_matrix/client/unstable/im.nheko.summary/rooms/.*/summary$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/account/3pid$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/devices$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/keys/query$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/keys/changes$
            - ^/_matrix/client/versions$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/voip/turnServer$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/joined_groups$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/publicised_groups$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/publicised_groups/
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/event/
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/joined_rooms$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/search$
          workers:
            client1: 8521
            client2: 8522
        - rest:
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/login$
            - ^/_matrix/client/(r0|v3|unstable)/register$
            - ^/_matrix/client/v1/register/m.login.registration_token/validity$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/login/sso/redirect
            - ^/_synapse/client/pick_idp$
            - ^/_synapse/client/pick_username
            - ^/_synapse/client/new_user_consent$
            - ^/_synapse/client/sso_register$
            - ^/_synapse/client/oidc/callback$
            - ^/_synapse/client/saml2/authn_response$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/login/cas/ticket$
          workers:
            login: 8531 # There can be only one login worker
        - rest:
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/redact
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/send
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/state/
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/(join|invite|leave|ban|unban|kick)$
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/join/
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/profile/
          workers:
            event1: 8541
            event2: 8542
      pusher:
        - workers:
            pusher1: 8551
            pusher2: 8552
      appservice:
        - workers:
            appservice: 8561
      federation_sender:
        - workers:
            federation_sender1: 8571
            federation_sender2: 8572
      media_repository:
        - rest:
            - ^/_matrix/media/
          workers:
            media1: 8581
            media2: 8582
          resources:
          - media
      user_dir:
        - rest:
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/user_directory/search$
          workers:
            user_dir: 8591
      frontend_proxy:
        - rest:
            - ^/_matrix/client/(api/v1|r0|v3|unstable)/keys/upload
          workers:
            frontend_proxy: 8601
          config:
            - worker_main_http_uri: http://127.0.0.1:8008

      
    appservices:
      discord:
        repo: https://github.com/Half-Shot/matrix-appservice-discord.git
        branch: develop
        client_id: 672058964707377152
        appservice_id: 330d1b6dcdf6a2217454f8227d2a960030d341a8baca5fa5c40f4081b6f40acd
        build: True
        script: /usr/bin/node build/src/discordas.js -c config.yaml -f discord-registration.yaml -p 9001
      webhook:
        repo: https://github.com/matrix-org/matrix-hookshot.git
        branch: main
        appservice_id: f4de7550133374c703c4cd64c5898cf1b82b65d4a5c2aca93863ee1fb859df91
        build: True
        script: /usr/bin/node App/BridgeApp.js config.yaml webhook-registration.yaml
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
                - root: /usr/share/webapps/element
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
                - location /vector-icons/:
                    - rewrite: ^(.*?)\..*?(\..*?)$ $1$2 last
                    - proxy_set_header: Host static.opensuse.org
                    - proxy_pass: https://static.opensuse.org/chat/favicons/
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
                    - return: 301 https://chat.opensuse.org
                - location ~ "/..*":
                    - proxy_set_header: X-Forwarded-For $remote_addr
                    - proxy_pass: http://localhost:8184
                - location /img/avatars/:
                    - proxy_set_header: Host static.opensuse.org
                    - proxy_pass: https://static.opensuse.org/chat/integrations/
          enabled: True
        matrix.opensuse.org:
          config:
            - server:
                - server_name: matrix.opensuse.org
                - listen:
                    - 80
                - location /:
                    - return: 301 https://chat.opensuse.org
                - location /_matrix:
                    - proxy_set_header: X-Forwarded-For $remote_addr
                    - proxy_pass: http://localhost:8008
                - include: /etc/matrix-synapse/workers/nginx.conf
          enabled: True
        webhook.opensuse.org:
          config:
            - server:
                - server_name: webhook.opensuse.org
                - listen:
                    - 80
                - location /:
                    - return: 301 https://chat.opensuse.org
                - location ~ "/..*":
                    - proxy_set_header: X-Forwarded-For $remote_addr
                    - proxy_pass: http://localhost:9005
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
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/matrix/openSUSE_Tumbleweed/
      priority: 100
      refresh: True
#   devel:languages:python:backports:
#     baseurl: https://download.opensuse.org/repositories/devel:/languages:/python:/backports/openSUSE_Leap_$releasever/
#     refresh: True
