include:
{% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.mailman3
{% endif %}
  - role.common.nginx

# Special config for mailman in the postfix relay
profile:
  postfix:
    maincf:
      recipient_delimiter: '+'
      owner_request_special: 'no'
      transport_maps: 'lmdb://var/lib/mailman/data/postfix_lmtp,lmdb:/etc/postfix/transport,lmdb:/etc/postfix/ratelimit'
      local_recipient_maps: 'lmdb://var/lib/mailman/data/postfix_lmtp'
      relay_domains: 'lmdb://var/lib/mailman/data/postfix_domains'
    aliases:
      mailman: root
  mailman3:
    admin_user: mailman
    database_user: mailman
    database_host: postgresql.infra.opensuse.org
    server_list:
      - lists.opensuse.org
      - lists.uyuni-project.org
      - mailman3.infra.opensuse.org

nginx:
  servers:
    managed:
      lists.opensuse.org.conf:
        config:
          #- map $request_uri $mails_rewritemap:
          #    - include: /etc/nginx/mails.rewritemap
          - map $request_uri $lists_rewritemap:
              - include: /etc/nginx/lists.rewritemap
          - map $request_uri $feeds_rewritemap:
              - include: /etc/nginx/feeds.rewritemap
          - map $request_uri $mboxs_rewritemap:
              - include: /etc/nginx/mboxs.rewritemap
          - map $request_uri $miscs_rewritemap:
              - include: /etc/nginx/miscs.rewritemap
          - upstream mailmanweb:
              - server: 127.0.0.1:8000 fail_timeout=0
          - server:
              - server_name: lists.opensuse.org lists.uyuni-project.org
              - listen: '[::]:80 default_server'
              - proxy_send_timeout: 600
              - proxy_read_timeout: 600
              - send_timeout: 600
              - if ($lists_rewritemap):
                  - rewrite: ^(.*)$ $lists_rewritemap permanent
              - if ($feeds_rewritemap):
                  - rewrite: ^(.*)$ $feeds_rewritemap permanent
              - if ($mboxs_rewritemap):
                  - rewrite: ^(.*)$ $mboxs_rewritemap permanent
              - if ($miscs_rewritemap):
                  - rewrite: ^(.*)$ $miscs_rewritemap permanent
              - 'location ~ "^/[^/]+/[0-9]{4}-[0-9]{2}/msg[0-9]+\.html"':
                  - proxy_pass: 'http://[::1]:44311'
                  - proxy_redirect: 'off'
                  - proxy_set_header: 'Host $host'
              - location /static/django-mailman3/img/login/opensuse.png:
                  - return: 301 https://static.opensuse.org/favicon-24.png
              - location /static/:
                  - alias: /srv/www/webapps/mailman/web/static/
              - location /:
                  - try_files: $uri @mailmanweb
              - location @mailmanweb:
                  - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                  - proxy_set_header: X-Forwarded-Proto https
                  - proxy_set_header: X-Forwarded-Protocol ssl
                  - proxy_set_header: Host $http_host
                  - proxy_redirect: "off"
                  - client_max_body_size: 10M
                  - proxy_pass: http://mailmanweb
        enabled: True

groups:
  memcached:
    system: true
    members:
      - mailmanweb

memcached:
  listen_socket: /run/memcached/memcached.sock
  memory_cap: 8192
  slab_size_limit: 64m
  unix_mask: 660

zypper:
  packages:
    archrwr: {}
