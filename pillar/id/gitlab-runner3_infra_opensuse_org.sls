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
  - forgejo.runner.internal
  - gitlab_runner

profile:
  forgejo:
    runner:
      config:
        server:
          connections:
            forgejo-internal:
              uuid: 32306338-3064-6461-3263-303666666664
