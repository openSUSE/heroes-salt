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
    - gitlab-runner3.infra.opensuse.org
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
              uuid: 64656636-6532-6264-3237-623939316333
