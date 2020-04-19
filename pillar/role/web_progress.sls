include:
  - role.common.nginx

nginx:
  ng:
    servers:
      managed:
        progress.opensuse.org.conf:
          config:
            - server:
                - listen: 80
                - server_name: progress.opensuse.org
                - server_tokens: 'off'
                - client_max_body_size: 20m
                # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
                - add_header: Strict-Transport-Security max-age=15768000
                - access_log: /var/log/nginx/redmine.access.log combined
                - error_log: /var/log/nginx/redmine.error.log
                - location /:
                    - try_files: $uri/index.html $uri.html $uri @cluster
                - location @cluster:
                    - proxy_pass: http://127.0.0.1:3000
                    - proxy_set_header: Host $host
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                - error_page: 500 502 503 504 /50x.html
                - location = /50x.html:
                    - root: /srv/www/htdocs
          enabled: True
