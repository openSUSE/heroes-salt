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

{% for xinetd_service in ['nrpe', 'check_mk'] %}
/etc/xinetd.d/{{ xinetd_service }}:
  file.managed:
    - contents:
    - source: salt://profile/monitoring/files/xinetd-{{ xinetd_service }}
    - user: root
    - group: root
    - mode: 444
{% endfor %}

xinetd:
  pkg.installed: []
  service.running:
    - enable: True
