sudoers:
  included_files:
    /etc/sudoers.d/nagios_nopasswd_sign:
      users:
        nagios:
          - 'ALL=(ALL) NOPASSWD: /usr/bin/sign -t'
