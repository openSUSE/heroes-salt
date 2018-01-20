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
          include:
            - mime.types
            - conf.d/*.conf
            - vhosts.d/*.conf
          set_real_ip_from: 192.168.47.4
          real_ip_header: X-Forwarded-For
          real_ip_recursive: 'on'
        worker_processes: 1
