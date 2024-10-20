include:
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.web_tsp
  {% endif %}
  - role.common.nginx

profile:
  web_tsp:
    database_host: postgresql.infra.opensuse.org
    database_user: web_tsp

nginx:
  servers:
    managed:
      tsp.opensuse.org.conf:
        config:
          - upstream tsp:
            - server: unix:///run/tsp/puma.socket
          - server:
              - listen: '[::]:80 default_server'
              - server_name: tsp.opensuse.org
              - root: /srv/www/travel-support-program/public
              - keepalive_timeout: 5
              - try_files $uri/index.html $uri @tsp
              - location @tsp:
                  - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                  - proxy_set_header: Host $http_host
                  - proxy_pass http://tsp
              - error_page: 500 502 503 504 /50x.html
              - location = /50x.html:
                  - root: /srv/www/htdocs
              - access_log: /var/log/nginx/tsp.access.log combined
              - error_log: /var/log/nginx/tsp.error.log
        enabled: True
