{%- from 'macros.jinja' import redis %}

include:
{%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.calendar
{%- endif %}
  - role.common.nginx

profile:
  calendar:
    database_name: calendar
    database_user: calendar
    database_host: postgresql.infra.opensuse.org
    # OIDC secret is in pillar/secrets/role/calendar.sls
    openidc:
      client_id: calendar.opensuse.org

nginx:
  servers:
    managed:
      calendar.opensuse.org.conf:
        config:
          - server:
              - listen: '[::]:80 default_server'
              - server_name: calendar.opensuse.org
              - root: /srv/www/calendar-o-o/public
              - client_max_body_size: 20m
              - keepalive_timeout: 5
              - try_files $uri/index.html $uri @calendar
              {%- for location in ['@calendar', '/cable'] %}
              - location {{ location }}:
                  - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                  - proxy_set_header: Host $http_host
                  - proxy_pass: 'http://unix:/run/calendar/puma'
              {%- endfor %}
                  - proxy_set_header: Upgrade $http_upgrade
              - error_page: 500 502 503 504 /50x.html
              - location = /50x.html:
                  - root: /srv/www/htdocs
              - access_log: /var/log/nginx/calendar.access.log combined
              - error_log: /var/log/nginx/calendar.error.log
        enabled: True

{{ redis('calendar', True) }}
