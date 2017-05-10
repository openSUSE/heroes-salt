# auditd provides a better log format for AppArmor events
auditd:
  pkg.installed:
    - name: audit
  service.running:
    - enable: True
