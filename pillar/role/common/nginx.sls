{% set site = salt['grains.get']('site') %}

firewalld:
  zones:
    internal:
      services:
        - prometheus-nginx_exporter

nginx:
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
        log_format: >-
          main
          '$remote_addr "$http_x_forwarded_for" [$time_iso8601] "$request"
          $status $body_bytes_sent $http_referer
          "$http_user_agent"'
        {%- if site == 'prg2' %}
        set_real_ip_from:
          - 2a07:de40:b27e:1204::11
          - 2a07:de40:b27e:1204::12
        {%- endif %}
        real_ip_header: X-Forwarded-For
        real_ip_recursive: 'on'
      worker_processes: auto
  servers:
    managed:
      status.conf:
        config:
          - server:
              - listen:
                  - unix:/run/nginx/status.sock
              - location = /:
                  - access_log: 'off'
                  - stub_status: ''
        enabled: true

prometheus:
  wanted:
    component:
      - nginx_exporter
  pkg:
    component:
      nginx_exporter:
        name: prometheus-nginx_exporter
        service:
          name: prometheus-nginx_exporter.socket

zypper:
  packages:
    nginx-logrotate-recompress: {}
