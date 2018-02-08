{% if saltenv == 'production' %}
{% set ip4_private = salt['grains.get']('ip4_interfaces:private')[0] %}
{% else %}
{% set ip4_private = '127.0.0.1' %}
{% endif %}

include:
  - role.common.nginx

nginx:
  ng:
    server:
      config:
        worker_processes: auto
    servers:
      managed:
        mirrors.opensuse.org.conf:
          config:
            - server:
                - listen: {{ ip4_private }}:80
                - location /:
                    - root: /srv/www/vhosts/mirrors.opensuse.org
                    - index:
                        - index.html
                        - index.htm
                - location = /50x.html:
                    - root: /srv/www/htdocs
          enabled: True
sudoers:
  included_files:
    /etc/sudoers.d/group_mirrors-admins:
      groups:
        mirrors-admins:
          - 'ALL=(ALL) ALL'
