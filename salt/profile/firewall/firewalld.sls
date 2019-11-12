{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}

include:
  {% if osmajorrelease == 15.1 %}
  - firewalld
  {% endif %}

