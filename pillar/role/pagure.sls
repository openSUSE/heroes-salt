include:
{% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.pagure
{% endif %}
  - role.common.nginx

profile:
  pagure:
    database_user: pagure
    database_host: 192.168.47.4
    server_list:
      - code.opensuse.org
      - pagure01.infra.opensuse.org

nginx:
  ng:
    servers:
      managed:
        code.opensuse.org.conf:
          config:
            - server:
                - server_name: code.opensuse.org
                - listen:
                    - 80
                    - default_server
                - location @pagure:
                    - proxy_set_header: Host $http_host
                    - proxy_set_header: X-Real-IP $remote_addr
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: X-Forwarded-Proto $scheme
                    - proxy_pass: http://unix:/srv/gitolite/.pagure_web.sock
                - location /:
                    - try_files: $uri @pagure
                - location /releases:
                    - alias: /srv/www/pagure-releases/
                    - autoindex: on
          enabled: True
        pages.opensuse.org.conf:
          config:
            - server:
                - server_name: pages.opensuse.org
                - listen:
                    - 80
                - location @pagure_docs:
                    - proxy_set_header: Host $http_host
                    - proxy_set_header: X-Real-IP $remote_addr
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: X-Forwarded-Proto $scheme
                    - proxy_pass: http://unix:/srv/gitolite/.pagure_docs_web.sock
                - location /:
                    - try_files: $uri @pagure_docs
          enabled: True
