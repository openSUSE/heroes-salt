sudoers:
  included_files:
    /etc/sudoers.d/nagios_nopasswd_hypervisors:
      users:
        nagios:
          - 'ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/check_md_raid, /sbin/multipath, /usr/bin/ipmitool'
