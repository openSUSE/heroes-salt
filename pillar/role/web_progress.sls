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
                    - http://127.0.0.1:3000
                    - fail_timeout=0
            - server:
                - listen: 80
                - server_tokens: 'off'
                # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
                - add_header: Strict-Transport-Security max-age=15768000
                - location /:
                    - try_files: $uri/index.html $uri.html $uri @cluster
                - location @cluster:
                    - proxy_pass: http://redmine
                - access_log: /var/log/nginx/redmine.access.log combined
                - error_log: /var/log/nginx/redmine.error.log
          enabled: True
