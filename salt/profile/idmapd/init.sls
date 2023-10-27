{%- set file = '/etc/idmapd.conf' %}

{{ file }}:
  file.managed:
    - source: salt://{{ slspath }}/files{{ file }}
    - template: jinja
