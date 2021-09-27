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
            {% if country == 'de' %}
            # HA proxies
            - 192.168.47.4
            - 192.168.47.101
            - 192.168.47.102
            # login proxies
            - 192.168.47.16
            - 192.168.47.21
            - 192.168.47.22
            - 172.16.42.3
            {% elif country == 'us' %}
            - 192.168.67.1
            - 192.168.67.2
            - 192.168.67.3
            {% endif %}
          real_ip_header: X-Forwarded-For
          real_ip_recursive: 'on'
        worker_processes: auto
