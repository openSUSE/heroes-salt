sudoers:
  users:
    osem:
      - 'ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem-dj'
      - 'ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem'
