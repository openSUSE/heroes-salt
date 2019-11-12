etckeeper_install:
  pkg.installed:
    - name: etckeeper

etckeeper_init:
  cmd.run:
    - name: etckeeper init
    - creates: /etc/.git

etckeeper_timer:
  service.running:
    - name: etckeeper.timer
    - enable: True
