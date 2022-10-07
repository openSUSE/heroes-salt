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
      transport_maps: 'hash://var/lib/mailman/data/postfix_lmtp,hash:/etc/postfix/transport,hash:/etc/postfix/ratelimit'
      local_recipient_maps: 'hash://var/lib/mailman/data/postfix_lmtp'
      relay_domains: 'hash://var/lib/mailman/data/postfix_domains'
    aliases:
      mailman: root
  mailman3:
    admin_user: mailman
    database_user: mailman
    database_host: 192.168.47.4
    server_list:
      - lists.opensuse.org
      - lists.uyuni-project.org
      - mailman3.infra.opensuse.org

nginx:
  ng:
    servers:
      managed:
        lists.opensuse.org.conf:
          config:
            - map $request_uri $mails_rewritemap:
                - include: /etc/nginx/mails.rewritemap
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
                - listen:
                    - 80
                    - default_server
                - if ($mails_rewritemap):
                    - rewrite: ^(.*)$ $mails_rewritemap permanent
                - if ($lists_rewritemap):
                    - rewrite: ^(.*)$ $lists_rewritemap permanent
                - if ($feeds_rewritemap):
                    - rewrite: ^(.*)$ $feeds_rewritemap permanent
                - if ($mboxs_rewritemap):
                    - rewrite: ^(.*)$ $mboxs_rewritemap permanent
                - if ($miscs_rewritemap):
                    - rewrite: ^(.*)$ $miscs_rewritemap permanent
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
                    - proxy_redirect: off
                    - proxy_pass: http://mailmanweb
          enabled: True

sudoers:
  included_files:
    /etc/sudoers.d/group_mailman3-admins:
      groups:
        mailman3-admins:
          - 'ALL=(ALL) ALL'
