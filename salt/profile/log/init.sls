{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}
{% set roles = salt['pillar.get']('roles', []) %}

include:
  - rsyslog

rsyslog_host:
  host.present:
    - ip: {{ salt['pillar.get']('profile:log:rsyslog_host') }}
    - names:
        - monitor.infra.opensuse.org
        - syslog.infra.opensuse.org
        - monitor
        - syslog

systemd-logger:
  pkg.removed:
    - require_in:
        - pkg: rsyslog

# TODO: replace with a proper logrotate formula
{% if osmajorrelease in [12, 42] %}
logrotate.timer:
  service.running:
    - enable: True
{% endif %}
