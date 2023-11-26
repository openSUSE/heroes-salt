sudoers:
  included_files:
    /etc/sudoers.d/group_kanidm-admins:
      groups:
        kanidm-admins:
          - 'ALL=(ALL) ALL'
