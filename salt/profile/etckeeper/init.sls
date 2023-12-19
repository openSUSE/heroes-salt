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

{% set host_id = salt['grains.get']('id') %}

etckeeper_git_config_name:
  git.config_set:
    - name: user.name
    - value: etckeeper
    - repo: /etc

etckeeper_git_config_email:
  git.config_set:
    - name: user.email
    - value: etckeeper@{{ host_id }}
    - repo: /etc
