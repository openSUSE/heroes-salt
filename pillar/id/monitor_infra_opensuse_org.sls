grains:
  site: prg2
  hostusage:
    - heroes-bot
    - monitor.o.o
    - syslog.i.o.o
  reboot_safe: yes

  aliases: []
  description: Monitoring server running various Prometheus components, Grafana, a syslog server and an IRC Bot
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Monitorinfraopensuseorg
  responsible:
    - crameleon
  partners: []
  weburls:
    - https://monitor.opensuse.org
    - https://alerts.infra.opensuse.org
    - https://prometheus.infra.opensuse.org
roles:
  - syslog
  - monitoring.master
  - monitoring.alertmanager
