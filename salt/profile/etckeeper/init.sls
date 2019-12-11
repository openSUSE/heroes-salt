etckeeper_install:
  pkg.installed:
    - pkgs:
      - etckeeper
      - etckeeper-zypp-plugin

etckeeper_init:
  cmd.run:
    - name: etckeeper init
    - creates: /etc/.git

etckeeper_timer:
  service.running:
    - name: etckeeper.timer
    - enable: True
