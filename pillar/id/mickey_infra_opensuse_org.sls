grains:
  site: prg2
  hostusage:
    - git.i.o.o
  reboot_safe: yes

  aliases: []
  description: Forgejo Server
  documentation: []
  responsible: []
  partners: []
  weburls:
    - https://git.infra.opensuse.org
roles:
  - forgejo.server.internal

network:
  interfaces:
    os-internal:
      addresses:
        # secondary address for binding Forgejo to
        - 2a07:de40:b27e:1203::b44/64
