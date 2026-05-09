grains:
  site: slc1
  hostusage:
    - Forgejo Runner
  reboot_safe: yes

  aliases: []
  description: Forgejo CI/CD Runner
  documentation: []
  responsible:
    - crameleon
  partners:
    - gitlab-runner1.infra.opensuse.org
    - gitlab-runner2.infra.opensuse.org
    - gitlab-runner3.infra.opensuse.org
  weburls: []
roles:
  - forgejo.runner.internal

profile:
  forgejo:
    runner:
      config:
        server:
          connections:
            forgejo-internal:
              uuid: 64656636-6532-6264-3237-623939316333
