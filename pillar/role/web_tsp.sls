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
            - server:
                - listen:
                    - 80
                    - default_server
                - server_name: tsp.opensuse.org
                - root: /srv/www/htdocs
                - location /:
                    - proxy_pass: http://127.0.0.1:3000
                - error_page: 500 502 503 504 /50x.html
                - location = /50x.html:
                    - root: /srv/www/htdocs
                - access_log: /var/log/nginx/tsp.access.log combined
                - error_log: /var/log/nginx/tsp.error.log
          enabled: True
