sudoers:
  included_files:
    /etc/sudoers.d/openqa_trusted_group_nopasswd:
      groups:
        trusted:
          - 'ALL=(ALL) NOPASSWD: ALL'
