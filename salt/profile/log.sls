# TODO: replace with a proper logrotate formula
{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}

{% if osmajorrelease in ['12', '42'] %}
logrotate.timer:
  service.running:
    - enable: True
{% endif %}
