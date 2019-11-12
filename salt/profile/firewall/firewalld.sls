{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}

include:
  {% if osmajorrelease == 15 %}
  - firewalld
  {% endif %}
