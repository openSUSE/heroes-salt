sudoers:
  included_files:
    /etc/sudoers.d/group_ipsilon-admins:
      groups:
        ipsilon-admins:
          - 'ALL=(ALL) ALL'
