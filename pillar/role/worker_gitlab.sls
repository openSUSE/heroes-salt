sudoers:
  included_files:
    /etc/sudoers.d/gitlab-runner_nopasswd_salt_event:
      users:
        gitlab-runner:
          - 'ALL=(root) NOPASSWD:SETENV: /usr/bin/salt-call event.*'
