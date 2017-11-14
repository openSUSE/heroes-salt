{% for dir in ['/etc/nrpe.d', '/etc/nagios'] %}
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

/etc/nagios/check_zypper-ignores.txt:
  file.managed:
    - source: salt://profile/monitoring/files/check_zypper-ignores.txt
    - template: jinja
    - user: root
    - group: root
    - mode: 444
