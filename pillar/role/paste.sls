include:
{% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.paste
{% endif %}
  - role.common.nginx

profile:
  paste:
    database_name: paste
    database_user: paste
    database_host: 192.168.47.4
    # OIDC secret and s3 secrets are in pillar/secrets/role/paste.sls
    openidc:
      client_id: paste.opensuse.org

nginx:
  ng:
    servers:
      managed:
        paste.opensuse.org.conf:
          config:
            - server:
                - listen:
                    - 80
                    - default_server
                - server_name: paste.opensuse.org
                - root: /srv/www/paste-o-o/public
                - client_max_body_size: 20m
                - keepalive_timeout: 5
                - try_files $uri/index.html $uri @paste
                - location @paste:
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: Host $http_host
                    - proxy_pass http://localhost:3000
                - error_page: 500 502 503 504 /50x.html
                - location = /50x.html:
                    - root: /srv/www/htdocs
                - access_log: /var/log/nginx/paste.access.log combined
                - error_log: /var/log/nginx/paste.error.log
          enabled: True

zypper:
  repositories:
    devel:languages:ruby:
      baseurl: http://download.infra.opensuse.org/repositories/devel:/languages:/ruby/$releasever/
      priority: 100
      refresh: True
