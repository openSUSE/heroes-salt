{% set osmajorrelease = salt['grains.get']('osmajorrelease')|int %}

etckeeper_install:
  pkg.installed:
    - pkgs:
      - etckeeper
      - etckeeper-zypp-plugin

etckeeper_init:
  cmd.run:
    - name: etckeeper init
    - creates: /etc/.git

{% if osmajorrelease > 12 %}
etckeeper_timer:
  service.running:
    - name: etckeeper.timer
    - enable: True
{% endif %}
