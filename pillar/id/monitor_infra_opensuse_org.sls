grains:
  city: prague
  country: cz
  hostusage:
    - heroes-bot
    - monitor.o.o
    - syslog.i.o.o
  reboot_safe: yes
  virt_cluster: falkor

  aliases: []
  description: Monitoring server running Icinga2 and an IRC Bot
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Monitorinfraopensuseorg
  responsible: []
  partners: []
  weburls:
    - https://monitor.opensuse.org
roles:
  - ircbot
  - syslog
  - monitoring
