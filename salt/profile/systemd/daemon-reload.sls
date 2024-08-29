systemd_reload_daemon:
  module.run:
    - service.systemctl_reload: {}
    - onlyif: systemctl show -PNeedDaemonReload $(find /etc/systemd/system -type f -name '*.service' -not -name '*@.service' -printf '%f ') | grep -q yes
    - order: last
