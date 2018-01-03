sudoers:
  included_files:
    /etc/sudoers.d/group_ircbot-admins:
      groups:
        ircbot-admins:
          - 'ALL=(root) /usr/bin/su - supybot,/usr/sbin/rcsupybot *'
