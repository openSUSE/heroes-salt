grains:
  site: prg2
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
    - gitlab-runner3.infra.opensuse.org
    - gitlab-runner4.infra.opensuse.org
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
              uuid: 63326164-6566-3137-6230-346130613533
