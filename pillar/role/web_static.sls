{% set websites = ['html5test', 'fontinfo', 'people', 'shop', 'static', 'studioexpress', 'lizards', 'www', 'community', 'ignite', 'oom', 'mirrors'] %}

{%- if grains.get('site') in ['nue-ipx', 'prv1'] %} {#- no IPv6 yet in NUE/PRV #}
{%- set listen = '80' %}
{%- else %}
{%- set listen = '[::]:80' %}
{%- endif %}

include:
  - role.common.nginx

nginx:
  servers:
    managed:
      {% for website in websites %}
      {{ website }}.opensuse.org.conf:
        config:
          - map $sent_http_content_type $expires:
              - text/css: 7d
              - image/x-icon: 90d
              - ~application/: 28d
              - ~font/: 28d
              - ~text/: 1h
              - ~image/: 28d
          - server:
              - server_name: {{ website }}.opensuse.org
              - listen:
                  {%- if website == 'static' %}
                  - '{{ listen }} default_server'
                  {%- else %}
                  - '{{ listen }}'
                  {%- endif %}
              - root: /srv/www/vhosts/{{ website }}.opensuse.org
              - gzip_vary: 'on'
              - gzip_min_length: 1000
              - gzip_comp_level: 5
              - gzip_types: text/plain text/xml text/x-js application/json text/css application/x-javascript application/javascript
              - expires: $expires
              - location ~ /\.svn:
                  - return: 404
              - location ~ /\.git:
                  - return: 404
              - location /:
                  - index: index.html index.htm
              - location ~* \.(?:ttf|otf|eot|woff)$:
                  - add_header: Access-Control-Allow-Origin "*"
              {% if website == 'static' %}
              - location ~ ^/chat/:
                  - add_header: Access-Control-Allow-Origin "*"
              - location ~ ^/themes/:
                  - autoindex: 'on'
              {% endif %}
              {%- if website == 'community' %}
              - autoindex: 'on'
              {%- endif %}
              {%- if website == 'mirrors' %}
              - rewrite: ^/report/mirrors/(.*)$ https://download.opensuse.org/report/mirrors/$1 redirect
              {%- endif %}
              - error_page: 405 = $uri
              - error_page: 405 =200 $uri
              - error_page: 500 502 503 504 /50x.html
              - location = /50x.html:
                  - root: /srv/www/htdocs
              - access_log: /var/log/nginx/{{ website }}.access.log combined
              - error_log: /var/log/nginx/{{ website }}.error.log
        enabled: True
      {% endfor %}

profile:
  web_static:
    ssh_pubkey: 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVddqh51YNoPglOnSZ9BpYH1nXzBV5ahbu0yncyL+6s web_static@salt'
    websites: {{ websites }}
  postfix:
    aliases:
      web_static: root

zypper:
  packages:
    rsync: {}
