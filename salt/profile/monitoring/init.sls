{% for dir in ['/etc/nrpe.d', '/etc/monitoring-plugins'] %}
{{ dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
{% endfor %}

{% set checks = salt['pillar.get']('monitoring:checks', {}) %}
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
