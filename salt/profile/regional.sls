{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}

include:
  - locale
  {% if osmajorrelease == 11 %}
  - ntp.ng
  {% endif %}
  - timezone
