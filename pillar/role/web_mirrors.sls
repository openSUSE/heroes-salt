{% set ip4_private = salt['grains.get']('ipv4_interfaces:private[0]') %}

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
