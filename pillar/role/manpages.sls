{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.manpages
{%- endif %}

rsync:
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
        - 2a07:de40:b27e:1204::11/128  # atlas1
        - 2a07:de40:b27e:1204::12/128  # atlas2
