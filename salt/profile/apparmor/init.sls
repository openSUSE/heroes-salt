include:
  {% if salt['pillar.get']('apparmor:auditd', True) %}
  - profile.apparmor.auditd
  {% endif %}
  - profile.apparmor.local-overrides
  - profile.apparmor.packages
  - profile.apparmor.profiles
