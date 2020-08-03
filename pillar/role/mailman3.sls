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
      transport_maps: 'hash://var/lib/mailman/data/postfix_lmtp'
      local_recipient_maps: 'hash://var/lib/mailman/data/postfix_lmtp'
      relay_domains: 'hash://var/lib/mailman/data/postfix_domains'
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
            - server:
                - server_name: lists.opensuse.org
                - listen:
                    - 80
                    - default_server
                - server: unix:///var/lib/mailman/server.sock
          enabled: True

sudoers:
  included_files:
    /etc/sudoers.d/group_mailman3-admins:
      groups:
        mailman3-admins:
          - 'ALL=(ALL) ALL'
