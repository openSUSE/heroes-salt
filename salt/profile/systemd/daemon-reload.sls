systemd_reload_daemon:
  module.run:
    - service.systemctl_reload: {}
    - onlyif: systemctl show -PNeedDaemonReload $(find /etc/systemd/system -maxdepth 1 -mindepth 1 \( -name '*.service' -or -name '*.service.d' \) -not -name '*@.service' -printf '%f ' | sed 's/\.d / /g') | grep -q yes
    - order: last
