grains:
  site: slc1
  hostusage:
    - GitLab Runner
  reboot_safe: yes

  aliases: []
  description: GitLab CI/CD runner/worker
  documentation:
    - https://docs.gitlab.com/runner/
  responsible:
    - crameleon
  partners:
    - gitlab-runner1.infra.opensuse.org
    - gitlab-runner2.infra.opensuse.org
    - gitlab-runner4.infra.opensuse.org
  weburls: []
roles:
  - gitlab_runner
