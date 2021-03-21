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
    appservices:
      discord:
        repo: https://github.com/Half-Shot/matrix-appservice-discord.git
        branch: develop
        client_id: 672058964707377152
        appservice_id: 330d1b6dcdf6a2217454f8227d2a960030d341a8baca5fa5c40f4081b6f40acd
        build: True
        script: /usr/bin/node build/src/discordas.js -c config.yaml -f discord-registration.yaml -p 9001
      webhook:
        repo: https://github.com/turt2live/matrix-appservice-webhooks.git
        appservice_id: f4de7550133374c703c4cd64c5898cf1b82b65d4a5c2aca93863ee1fb859df91
        build: False
        script: /usr/bin/node index.js -c config.yaml -f webhook-registration.yaml -p 9002
    telegram:
      appservice_id: oepzkscngbyqvopzn773ns7whfxyfslgjhy7mumy7syurqp3f4kvb4sgufz9nfsw
      api_id: 1331253
    matterbridge:
      servers:
        irc:
          freenode:
            Server: "chat.freenode.net:6697"
            UseTLS: true
            Nick: "openSUSEBot"
            RemoteNickFormat: "<{NICK}> "
        matrix:
          openSUSE:
            Server: "https://matrix.opensuse.org"
            Login: "matterbridge"
            RemoteNickFormat: "<{NICK}> "
        discord:
          openSUSE:
            Server: "ID:366985425371398146"
            AutoWebhooks: true
            UseUserName: true
            RemoteNickFormat: "{NICK}"
        telegram:
          default:
            UseFirstName: true
            RemoteNickFormat: "**{NICK}**: "
            MessageFormat: "MarkdownV2"
      gateways:
        kiwi:
          matrix.openSUSE: "#kiwi:matrix.org"
          discord.openSUSE: "ID:669467339158454283"
        kubic:
          irc.freenode: "#kubic"
          matrix.openSUSE: "#kubic:opensuse.org"
          discord.openSUSE: "ID:734445719825416216"
        microos-desktop:
          irc.freenode: "microos-desktop"
          matrix.openSUSE: "#microos-desktop:opensuse.org"
          discord.openSUSE: "ID:734445753975570563"
          telegram.default: ""
        openqa:
          matrix.openSUSE: "#openqa:opensuse.org"
          discord.openSUSE: "ID:817367056956653621"
        opensuse-admin:
          irc.freenode: "#opensuse-admin"
          matrix.openSUSE: "#admin:opensuse.org"
          discord.openSUSE: "ID:700799844754784420"
        opensuse-artwork:
          irc.freenode: "#opensuse-artwork"
          matrix.openSUSE: "#artwork:opensuse.org"
          discord.openSUSE: "ID:496049131928682506"
        opensuse-buildservice:
          irc.freenode: "#opensuse-buildservice"
          matrix.openSUSE: "#obs:opensuse.org"
          discord.openSUSE: "ID:723545727816433664"
        opensuse-chat:
          irc.freenode: "#opensuse-chat"
          matrix.openSUSE: "#chat:opensuse.org"
          discord.openSUSE: "ID:366989996101730304"
          telegram.default: ""
        opensuse-de:
          irc.freenode: "#opensuse-de"
          matrix.openSUSE: "#de:opensuse.org"
          discord.openSUSE: "ID:561164428939100160"
          telegram.default: ""
        opensuse-docs:
          matrix.openSUSE: "#docs:opensuse.org"
          discord.openSUSE: "ID:570871796132478976"
          telegram.default: ""
        opensuse-e:
          irc.freenode: "#opensuse-e"
          matrix.openSUSE: "#e:opensuse.org"
          discord.openSUSE: "ID:582568672196034570"
        opensuse-es:
          irc.freenode: "#opensuse-es"
          matrix.openSUSE: "#es:opensuse.org"
          discord.openSUSE: "ID:561190353030348810"
          telegram.default: ""
        opensuse-factory:
          irc.freenode: "#opensuse-factory"
          matrix.openSUSE: "#factory:opensuse.org"
          discord.openSUSE: "ID:523947864439914496"
        opensuse-forums:
          irc.freenode: "#opensuse-forums"
          matrix.openSUSE: "#forums:opensuse.org"
          discord.openSUSE: "ID:700825520668934284"
        opensuse-fr:
          matrix.openSUSE: "#fr:opensuse.org"
          discord.openSUSE: "ID:664012710597492737"
        opensuse-gaming:
          matrix.openSUSE: "#gaming:opensuse.org"
          discord.openSUSE: "ID:570871874481815572"
        opensuse-gnome:
          irc.freenode: "#opensuse-gnome"
          matrix.openSUSE: "#gnome:opensuse.org"
          discord.openSUSE: "ID:523949043110379530"
        opensuse-haskell:
          matrix.openSUSE: "#haskell:opensuse.org"
          discord.openSUSE: "ID:760556011395874856"
        opensuse-it:
          matrix.openSUSE: "#it:opensuse.org"
          discord.openSUSE: "ID:561194459619000321"
          telegram.default: ""
        opensuse-kde:
          irc.freenode: "#opensuse-kde"
          matrix.openSUSE: "#kde:opensuse.org"
          discord.openSUSE: "ID:523949061674369024"
        opensuse-marketing:
          irc.freenode: "#opensuse-marketing"
          matrix.openSUSE: "#marketing:opensuse.org"
          discord.openSUSE: "ID:660902159910567966"
          telegram.default: ""
        opensuse-newscom:
          matrix.openSUSE: "#newscom:opensuse.org"
          discord.openSUSE: "ID:806162338188361728"
          telegram.default: ""
        opensuse-news:
          matrix.openSUSE: "#news:opensuse.org"
          discord.openSUSE: "ID:376527321869451271"
        opensuse-nl:
          matrix.openSUSE: "#nl:opensuse.org"
          discord.openSUSE: "ID:605150216965849107"
        opensuse-packaging:
          irc.freenode: "#opensuse-packaging"
          matrix.openSUSE: "#packaging:opensuse.org"
          discord.openSUSE: "ID:496005129959374868"
        opensuse-pine:
          matrix.openSUSE: "#pine:opensuse.org"
          discord.openSUSE: "ID:794874055043710996"
          telegram.default: ""
        opensuse-pl:
          irc.freenode: "#suse.pl"
          matrix.openSUSE: "#pl:opensuse.org"
          discord.openSUSE: "ID:561164407560863755"
          telegram.default: ""
        opensuse-project:
          irc.freenode: "#opensuse-project"
          matrix.openSUSE: "#project:opensuse.org"
          discord.openSUSE: "ID:407993213425680384"
          telegram.default: ""
        opensuse-reddit:
          matrix.openSUSE: "#reddit:opensuse.org"
          discord.openSUSE: "ID:619283903571820555"
        opensuse-support:
          irc.freenode: "#suse"
          matrix.openSUSE: "#support:opensuse.org"
          discord.openSUSE: "ID:366987951734784012"
        opensuse-telegram:
          matrix.openSUSE: "#telegram:opensuse.org"
          discord.openSUSE: "ID:557298959765209108"
          telegram.default: ""
        opensuse-tumbleweed:
          matrix.openSUSE: "#snapshots:opensuse.org"
          discord.openSUSE: "ID:619284844865650698"
        opensuse-twitter:
          matrix.openSUSE: "#twitter:opensuse.org"
          discord.openSUSE: "ID:619283940318117953"
        opensuse-xfce:
          irc.freenode: "#opensuse-xfce"
          matrix.openSUSE: "#xfce:opensuse.org"
          discord.openSUSE: "ID:523949083241742336"
          telegram.default: ""
        software-o-o:
          matrix.openSUSE: "#software-o-o:opensuse.org"
          discord.openSUSE: "ID:733713878055256155"
        uyuni:
          irc.freenode: "#uyuni"
          matrix.openSUSE: "#uyuni:opensuse.org"
          discord.openSUSE: "ID:723546275915628585"
        yast:
          irc.freenode: "#yast"
          matrix.openSUSE: "#yast:opensuse.org"
          discord.openSUSE: "ID:545922654570414090"

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
                - root: /usr/share/element-web
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
