{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.manpages
{%- endif %}

rsync:
  defaults:
    proxy protocol: true
  modules:
    rpm2docserv:
      auth users: docserv
      comment: Manual pages server data
      exclude: google897e15adbab60af5.html
      path: /srv/docserv
      read only: false
      uid: docserv
      gid: docserv
      hosts allow:
        - 10.151.132.20/32  # obs-gateway
        - 10.151.132.21/32  # obs-gateway1
        - 10.151.132.22/32  # obs-gateway2
