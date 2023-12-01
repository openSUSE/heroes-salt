{% set country = salt['grains.get']('country') %}

nginx:
  ng:
    lookup:
      server_available: /etc/nginx/vhosts.d
      server_enabled: /etc/nginx/vhosts.d
    server:
      config:
        events:
          worker_connections: 1024
          use: epoll
        http:
          gzip: 'on'
          server_tokens: 'off'
          include:
            - mime.types
            - conf.d/*.conf
            - vhosts.d/*.conf
          set_real_ip_from:
            {%- if country == 'us' %}
            - 192.168.67.1
            - 192.168.67.2
            - 192.168.67.3
            {%- elif country == 'cz' %}
            - 2a07:de40:b27e:1204::11
            - 2a07:de40:b27e:1204::12
            {%- endif %}
          real_ip_header: X-Forwarded-For
          real_ip_recursive: 'on'
        worker_processes: auto
