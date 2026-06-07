{%- set dir = '/etc/udev/rules.d' %}
{%- for file in salt['file.find'](dir, print='name', type='f') %}
  {%- if file not in [
        '70-persistent-net.rules',
        '80-salt-net.rules',
  ] %}
{{ dir }}/{{ file }}:
  file.absent
  {%- endif %}
{%- endfor %}
