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
      - mailman3.infra.opensuse.org

nginx:
  ng:
    servers:
      managed:
        lists.opensuse.org.conf:
          config:
            - map $request_uri $mails_rewritemap:
                - include /etc/nginx/mails.rewritemap
            - map $request_uri $lists_rewritemap:
                - include /etc/nginx/lists.rewritemap
            - map $request_uri $feeds_rewritemap:
                - include /etc/nginx/feeds.rewritemap
            - map $request_uri $mboxs_rewritemap:
                - include /etc/nginx/mboxs.rewritemap
            - server:
                - server_name: lists.opensuse.org
                - listen:
                    - 80
                    - default_server
                - if ($mails_rewrite:map):
                    - rewrite: ^(.*)$ $mails_rewrite:map permanent
                - if ($lists_rewrite:map):
                    - rewrite: ^(.*)$ $lists_rewrite:map permanent
                - if ($feeds_rewrite:map):
                    - rewrite: ^(.*)$ $feeds_rewrite:map permanent
                - if ($mboxs_rewrite:map):
                    - rewrite: ^(.*)$ $mboxs_rewrite:map permanent
                - location /archive/:
                    - return: 301 /archives/
                - location /cgi-bin/search.cgi:
                    - return: 301 /archives/search
                - location /stats:
                    - return: 301 /
                - location /static/django-mailman3/img/login/opensuse.png:
                    - return: 301 https://static.opensuse.org/favicon-24.png
                - location /static/:
                    - alias: /var/lib/mailman_webui/static/
                - location /:
                    - include: /etc/nginx/uwsgi_params
                    - uwsgi_pass: 0.0.0.0:8000
          enabled: True

sudoers:
  included_files:
    /etc/sudoers.d/group_mailman3-admins:
      groups:
        mailman3-admins:
          - 'ALL=(ALL) ALL'
