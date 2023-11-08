{%- set xinetdd = '/etc/xinetd.d/' %}

common_monitoring_packages:
  pkg.installed:
    - pkgs:
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
    - source: salt://profile/monitoring/files/nrpe.cfg.jinja
    - user: root
    - group: root
    - mode: 444
    - template: jinja

# cleanup old xinetd config for nrpe (pre-Leap 15.5)
{%- for file in ['nrpe', 'nrpe.rpmnew', 'nrpe.rpmsave', 'check_mk'] %}
{{ xinetdd }}{{ file }}:
  file.absent
{%- endfor %}

{%- set fe = salt['file.file_exists'] %}
{%- if not ( fe(xinetdd ~ 'csync2') or fe(xinetdd ~ 'nsca') or fe(xinetdd ~ 'vsftpd') or fe(xinetdd ~ 'livestatus') ) %}
xinetd:
  pkg.removed: []
  {%- if not opts['test'] %}
  service.dead:
    - enable: False
  {%- endif %}
{%- endif %}

nrpe.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/nrpe.cfg
      {%- for check in checks.keys() %}
      - file: /etc/nrpe.d/{{ check }}.cfg
      {%- endfor %}
