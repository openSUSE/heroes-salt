include:
  - role.common.nginx
{%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.manpages
{%- endif %}

rsync:
  defaults:
    proxy protocol: true
    proxy protocol hosts:
      - 2a07:de40:b27e:1204::11  # atlas1
      - 2a07:de40:b27e:1204::12  # atlas2
  modules:
    rpm2docserv:
      auth users: docserv
      comment: Manual pages server data
      exclude:
        - google897e15adbab60af5.html
        - Leap-*
      path: /srv/docserv
      read only: false
      uid: docserv
      gid: docserv
      hosts allow:
        - 10.151.132.20/32  # obs-gateway
        - 10.151.132.21/32  # obs-gateway1
        - 10.151.132.22/32  # obs-gateway2
