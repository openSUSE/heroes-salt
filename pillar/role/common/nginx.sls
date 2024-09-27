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
        set_real_ip_from:
          {%- if site == 'prv1' %}
          - 192.168.67.1
          - 192.168.67.2
          - 192.168.67.3
          {%- elif site == 'prg2' %}
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
