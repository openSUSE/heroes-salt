include:
  - role.common.nginx

nginx:
  ng:
    servers:
      managed:
        progress.opensuse.org.conf:
          config:
            - upstream redmine:
                - server:
                    - unix:/srv/www/vhosts/redmine/tmp/sockets/redmine.socket
                    - fail_timeout=0
            - server:
                - listen: 80
                - server_tokens: 'off'
                - set_real_ip_from: 192.168.47.4
                - set_real_ip_from: 192.168.47.101
                - set_real_ip_from: 192.168.47.102
                - set_real_ip_from: 192.168.47.16
                - set_real_ip_from: 172.16.42.3
                - real_ip_header: X-Forwarded-For
                # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
                - add_header: Strict-Transport-Security max-age=15768000
                - location /:
                    - try_files: $uri/index.html $uri.html $uri @cluster
                - location @cluster:
                    - proxy_pass: http://redmine
                - access_log: /var/log/nginx/redmine.access.log combined
                - error_log: /var/log/nginx/redmine.error.log
          enabled: True
