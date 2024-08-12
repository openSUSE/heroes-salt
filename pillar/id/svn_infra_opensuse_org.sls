grains:
  site: prg2
  hostusage:
    - svn_git
  reboot_safe: yes

  aliases: []
  description: Public (kernel) git and svn server.
  documentation: []
  responsible:
    - jdsn
  partners: []
  weburls:
    - https://svn.opensuse.org/
roles: []
firewalld:
  enabled: true
  zones:
    internal:
      interfaces:
        - os-internal
      services:
        - http
