include:
{% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.pagure
{% endif %}
  - role.common.nginx

sshd_config:
  matches:
    git_user:
      type:
        User: git
      options:
        AuthorizedKeysCommand: /usr/lib/pagure/keyhelper.py "%u" "%h" "%t" "%f"
        AuthorizedKeysCommandUser: git
    proxy:
      type:
        Address:
          - 192.168.47.4
          - 192.168.47.101
          - 192.168.47.102
      options:
        AllowUsers:
          - git
    external:
      type:
        Address:
          - 195.135.221.144
          - 2001:67c:2178:8::144
      options:
        AllowUsers:
          - git

profile:
  pagure:
    database_user: pagure
    database_host: postgresql.infra.opensuse.org

{% set listenhttps6=['[::]:443', 'ssl', 'http2'] %}

nginx:
  ng:
    servers:
      managed:
        redirhttp.conf:
          config:
            - server:
                - include: acme-challenge
                - server_name: '_'
                - listen:
                    - '[::]:80'
                    - default_server
                - location /:
                    - return: '301 https://$host$request_uri'
          enabled: True
        code.opensuse.org.conf:
          config:
            - server:
                - server_name: code.opensuse.org
                - listen: {{ listenhttps6 }}
                - include: ssl-config
                - location @pagure:
                    - client_max_body_size: 0
                    - proxy_set_header: Host $http_host
                    - proxy_set_header: X-Real-IP $remote_addr
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: X-Forwarded-Proto $scheme
                    - proxy_pass: http://unix:/srv/gitolite/.pagure_web.sock
                - location /:
                    - try_files: $uri @pagure
                - location /releases:
                    - alias: /srv/www/pagure-releases/
                    - autoindex: 'on'
          enabled: True
        releases.opensuse.org.conf:
          config:
            - server:
                - server_name: releases.opensuse.org
                - listen: {{ listenhttps6 }}
                - include: ssl-config
                - location /:
                    - alias: /srv/www/pagure-releases/
                    - autoindex: 'on'
          enabled: True
        ev.opensuse.org.conf:
          config:
            - server:
                - server_name: ev.opensuse.org
                - listen: {{ listenhttps6 }}
                - include: ssl-config
                - location @pagure_ev:
                    - proxy_set_header: Host $http_host
                    - proxy_set_header: X-Real-IP $remote_addr
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: X-Forwarded-Proto $scheme
                    - proxy_pass: http://localhost:8080
                - location /:
                    - try_files: $uri @pagure_ev
          enabled: True
        pages.opensuse.org.conf:
          config:
            - server:
                - server_name: pages.opensuse.org
                - listen: {{ listenhttps6 }}
                - include: ssl-config
                - location @pagure_docs:
                    - proxy_set_header: Host $http_host
                    - proxy_set_header: X-Real-IP $remote_addr
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: X-Forwarded-Proto $scheme
                    - proxy_pass: http://unix:/srv/gitolite/.pagure_docs_web.sock
                - location /:
                    - try_files: $uri @pagure_docs
          enabled: True

zypper:
  repositories:
    openSUSE:infrastructure:pagure:
      baseurl: http://download-prg.infra.opensuse.org/repositories/openSUSE:/infrastructure:/pagure/$releasever/
      priority: 100
      refresh: True
