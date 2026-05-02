grains:
  site: prg2
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
    - gitlab-runner2.infra.opensuse.org
    - gitlab-runner3.infra.opensuse.org
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
              uuid: 31626433-3061-3465-3033-333931326565
