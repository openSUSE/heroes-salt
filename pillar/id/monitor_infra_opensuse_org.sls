grains:
  city: nuremberg
  country: de
  hostusage:
    - heroes-bot
    - monitor.o.o
    - syslog.i.o.o
  roles:
    - ircbot
    - syslog
    - monitoring
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Monitoring server running Icinga, check_mk and an IRC Bot
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Monitorinfraopensuseorg
  responsible: []
  partners: []
  weburls:
    - https://monitor.opensuse.org
