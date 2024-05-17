/var/spool/prometheus:
  file.directory

/usr/local/libexec/systemd:
  file.directory:
    - mode: '0755'

{%- set roles_map = {
      'base': [
        'postfix-queue-size',
        'zypper',
      ],
    }
%}
{%- set collectors = roles_map['base'] %}
{%- for role in pillar.get('roles', []) %}
{%- if role in roles_map.keys() %}
{%- do collectors.extend(roles_map[role]) %}
{%- endif %}
{%- endfor %}

textfile_files:
  file.managed:
    - names:
        {%- set source = 'salt://' ~ slspath ~ '/files/textfile/' %}
        {%- for collector in collectors %}
        {%- set script = collector ~ '-metrics' %}
        - /usr/local/libexec/systemd/{{ script }}.sh:
            - source: {{ source }}scripts/{{ script }}.sh.jinja
            - group: monitor
            - mode: '0750'
        - /etc/systemd/system/{{ script }}.service:
            - source: {{ source }}systemd/{{ script }}.service.jinja
        - /etc/systemd/system/{{ script }}.timer:
            - source: {{ source }}systemd/{{ script }}.timer.jinja
        {%- endfor %}
        - /var/spool/prometheus/salt.prom:
            - source: {{ source }}salt.prom.jinja
        - /var/spool/prometheus/zypper.prom:
            - replace: False
            - user: monitor
    - template: jinja
    - require:
        - file: /usr/local/libexec/systemd

textfile_timers:
  service.running:
    - names:
        {%- for collector in collectors %}
        {%- set script = collector ~ '-metrics' %}
        - {{ script }}.timer:
            - watch:
                - file: /etc/systemd/system/{{ script }}.service
                - file: /etc/systemd/system/{{ script }}.timer
        {%- endfor %}
    - enable: True
    - require:
        - file: /var/spool/prometheus
        - file: /usr/local/libexec/systemd
