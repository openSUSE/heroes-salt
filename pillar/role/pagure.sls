{%- from 'macros.jinja' import redis %}

include:
{%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.pagure
{%- endif %}
  - role.common.nginx

firewalld:
  enabled: true
  zones:
    internal:
      interfaces:
        - os-code
      services:
        - http
        - https

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
          - 2a07:de40:b27e:1204::11  # atlas1
          - 2a07:de40:b27e:1204::12  # atlas2
      options:
        AllowUsers:
          - git

profile:
  pagure:
    database_user: pagure
    database_host: postgresql.infra.opensuse.org

{%- set listenhttps6='[::]:80' %}

nginx:
  servers:
    managed:
      code.opensuse.org.conf:
        config:
          - server:
              - server_name: code.opensuse.org
              - listen: '{{ listenhttps6 }}'
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
              - listen: '{{ listenhttps6 }}'
              - location /:
                  - alias: /srv/www/pagure-releases/
                  - autoindex: 'on'
        enabled: True
      ev.opensuse.org.conf:
        config:
          - server:
              - server_name: ev.opensuse.org
              - listen: '{{ listenhttps6 }}'
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
              - listen: '{{ listenhttps6 }}'
              - location @pagure_docs:
                  - proxy_set_header: Host $http_host
                  - proxy_set_header: X-Real-IP $remote_addr
                  - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                  - proxy_set_header: X-Forwarded-Proto $scheme
                  - proxy_pass: http://unix:/srv/gitolite/.pagure_docs_web.sock
              - location /:
                  - try_files: $uri @pagure_docs
        enabled: True

{{ redis('pagure') }}

groups:
  redis:
    members:
      - git

zypper:
  repositories:
    openSUSE:infrastructure:pagure:
      baseurl: http://download-prg.infra.opensuse.org/repositories/openSUSE:/infrastructure:/pagure/$releasever/
      priority: 100
      refresh: True
