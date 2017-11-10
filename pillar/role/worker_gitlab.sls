sudoers:
  included_files:
    /etc/sudoers.d/gitlab-runner_nopasswd_saltmaster_deploy:
      users:
        gitlab-runner:
          - 'ALL=(ALL) NOPASSWD: /usr/bin/salt-call event.fire_master update salt/fileserver/gitfs/update'
