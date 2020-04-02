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
