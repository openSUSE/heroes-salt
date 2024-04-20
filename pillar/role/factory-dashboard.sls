include:
  - role.common.nginx
{%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.factory-dashboard
{%- endif %}

{%- set website = 'factory-dashboard.opensuse.org' %}
{%- set webroot = '/srv/www/vhosts/' ~ website %}

nginx:
  servers:
    managed:
      {{ website }}.conf:
        enabled: True
        config:
          - map $sent_http_content_type $expires:
              - text/css: 7d
              - image/x-icon: 90d
              - ~application/: 28d
              - ~font/: 28d
              - ~text/: 28d
              - ~image/: 28d
          - server:
              - listen: '[::]:80 ipv6only=on'
              - server_name: {{ website }}
              - root: {{ webroot }}
              - gzip_vary: 'on'
              - gzip_min_length: 1000
              - gzip_comp_level: 5
              - gzip_types: text/plain text/xml text/x-js application/json text/css application/x-javascript application/javascript
              - location ~* \.(?:ttf|otf|eot|woff)$:
                  - add_header: Access-Control-Allow-Origin '*'
              - location = /check.txt:
                  - root: /srv/www/htdocs
                  - access_log: 'off'
              - error_page: 405 = $uri
              - error_page: 405 =200 $uri
              - error_page: 500 502 503 504 /50x.html
              - location = /50x.html:
                  - root: /srv/www/htdocs
              - access_log: /var/log/nginx/{{ website }}.access.log combined
              - error_log: /var/log/nginx/{{ website }}.error.log

rsync:
  modules:
    {{ website }}:
      auth users: coolo
      comment: A dashboard for openSUSE:Factory
      path: {{ webroot }}
      read only: false
      uid: dashboard
      hosts allow:
        - atlas1.infra.opensuse.org
        - atlas2.infra.opensuse.org

users:
  dashboard: {}
