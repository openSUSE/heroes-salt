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
    database_host: postgres.infra.opensuse.org
    server_list:
      - lists.opensuse.org
      - mailman3.infra.opensuse.org
