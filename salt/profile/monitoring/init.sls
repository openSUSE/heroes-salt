common_monitoring_packages:
  pkg.installed:
    - pkgs:
      - check_mk-agent
      - monitoring-plugins-common
      - nrpe

{% for dir in ['/etc/nrpe.d', '/etc/monitoring-plugins'] %}
{{ dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
{% endfor %}

{% set checks = salt['pillar.get']('profile:monitoring:checks', {}) %}
{% for check, cmd in checks.items() %}
/etc/nrpe.d/{{ check }}.cfg:
  file.managed:
    - contents:
      - "command[{{ check }}]={{ cmd }}"
    - user: root
    - group: root
    - mode: 444
{% endfor %}

/etc/monitoring-plugins/check_zypper-ignores.txt:
  file.managed:
    - source: salt://profile/monitoring/files/check_zypper-ignores.txt
    - template: jinja
    - user: root
    - group: root
    - mode: 444

/etc/nrpe.cfg:
  file.managed:
    - source: salt://profile/monitoring/files/nrpe.cfg
    - user: root
    - group: root
    - mode: 444

nrpe.service:
  service.running:
    - enable: True

# cleanup old xinetd config for nrpe (pre-Leap 15.5)
{% for file in ['nrpe', 'nrpe.rpmnew', 'nrpe.rpmsave'] %}
/etc/xinetd.d/{{ file }}:
  file.absent
{% endfor %}

/etc/xinetd.d/check_mk:
  file.managed:
    - contents:
    - source: salt://profile/monitoring/files/xinetd-check_mk
    - user: root
    - group: root
    - mode: 444

xinetd:
  pkg.installed: []
  service.running:
    - enable: True
