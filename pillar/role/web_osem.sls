sudoers:
  included_files:
    /etc/sudoers.d/group_osem:
      users:
        osem:
          - ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem-dj
          - ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem

