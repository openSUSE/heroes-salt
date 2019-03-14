sudoers:
  included_files:
    /etc/sudoers.d/osem:
      groups:
        osem-admins:
          - 'ALL=(ALL) ALL'
      users:
        osem:
          - 'ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem-dj'
          - 'ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem'
