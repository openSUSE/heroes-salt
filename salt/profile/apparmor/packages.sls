apparmor:
  pkg.installed:
    - pkgs:
      - apparmor-abstractions
      - apparmor-parser
{% if salt['pillar.get']('apparmor:defaultprofiles', True) %}
      - apparmor-profiles
{% endif %}
      - apparmor-utils

  service.running:
    - enable: True
    # restarting AppArmor means to remove confinement from running processes, so always use reload!
    - reload: True

# auditd provides a better log format for AppArmor events
{% if salt['pillar.get']('apparmor:auditd', True) %}
auditd:
  pkg.installed:
    - name: audit
  service.running:
    - enable: True
{% endif %}
