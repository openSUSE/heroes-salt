sudoers:
  included_files:
    /etc/sudoers.d/group_weblate-admins:
      groups:
        weblate-admins:
          - 'ALL=(ALL) ALL'
