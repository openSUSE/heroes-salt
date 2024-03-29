{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}
{% set roles = salt['pillar.get']('roles', []) %}

include:
  - rsyslog

{%- if grains['id'] != 'monitor.infra.opensuse.org' %}
rsyslog_host:
  host.present:
    - ip: {{ salt['pillar.get']('profile:log:rsyslog_host') }}
    - names:
        - monitor.infra.opensuse.org
        - syslog.infra.opensuse.org
        - monitor
        - syslog
    - clean: True
{%- endif %}

systemd-logger:
  pkg.removed:
    - require_in:
        - pkg: rsyslog
