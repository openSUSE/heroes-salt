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
