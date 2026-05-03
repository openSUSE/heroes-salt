grains:
  site: prg2
  hostusage:
    - git.i.o.o
    - gitlab.i.o.o
    - gitlab runner
  reboot_safe: yes

  aliases: []
  description: Forgejo/GitLab server
  documentation: []
  responsible: []
  partners: []
  weburls:
    - https://git.infra.opensuse.org
    - https://gitlab.infra.opensuse.org
roles:
  - forgejo.server.internal
  - web_gitlab

network:
  interfaces:
    os-internal:
      addresses:
        # secondary address for binding Forgejo to
        - 2a07:de40:b27e:1203::b44/64
