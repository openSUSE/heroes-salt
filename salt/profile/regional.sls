{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}

include:
  {% if osmajorrelease == 11 %}
  - ntp.ng
  {% else %}
  - chrony
  - chrony.config
  {% endif %}
  - locale
  - timezone
