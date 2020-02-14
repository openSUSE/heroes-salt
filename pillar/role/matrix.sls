{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.matrix
{% endif %}

profile:
  matrix:
    discord_client_id: 672058964707377152
    discord_appservice_id: 330d1b6dcdf6a2217454f8227d2a960030d341a8baca5fa5c40f4081b6f40acd
    discord_homeserver_token: c86278c9ee856a30120578811404ab9f87ab14e4ee245811cf008c78eb1d0c82
    discord_appservice_token: f23cb935c48801d921142fc0011d952b7108874eaae9182e5f229cdf9a1e81ab

sudoers:
  included_files:
    /etc/sudoers.d/group_matrix-admins:
      groups:
        matrix-admins:
          - 'ALL=(ALL) ALL'

zypper:
  repositories:
    openSUSE:infrastructure:matrix:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/matrix/openSUSE_Leap_$releasever/
      priority: 100
      refresh: True