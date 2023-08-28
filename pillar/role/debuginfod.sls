sudoers:
  included_files:
    /etc/sudoers.d/group_debuginfod-admins:
      groups:
        debuginfod-admins:
          - 'ALL=(ALL) ALL'
