include:
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.web_tsp
  {% endif %}
  - role.common.nginx

profile:
  web_tsp:
    database_host: 192.168.47.4
    database_user: web_tsp

nginx:
  ng:
    servers:
      managed:
        tsp.opensuse.org.conf:
          config:
            - upstream tsp:
              - server: unix:///var/cache/tsp/puma.socket
            - server:
                - listen:
                    - 80
                    - default_server
                - server_name: tsp.opensuse.org
                - root: /srv/www/travel-support-program/public
                - keepalive_timeout: 5
                - location /:
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: Host $http_host
                    - if (-f $request_filename):
                      - break
                    - if (-f $request_filename/index.html):
                      - rewrite: (.*) $1/index.html break
                    - if (-f $request_filename.html):
                      - rewrite: (.*) $1.html break
                    - if (!-f $request_filename):
                      - proxy_pass http://tsp
                      - break
                - error_page: 500 502 503 504 /50x.html
                - location = /50x.html:
                    - root: /srv/www/htdocs
                - access_log: /var/log/nginx/tsp.access.log combined
                - error_log: /var/log/nginx/tsp.error.log
          enabled: True

sudoers:
  included_files:
    /etc/sudoers.d/group_tsp-admins:
      groups:
        tsp-admins:
          - 'ALL=(ALL) ALL'
