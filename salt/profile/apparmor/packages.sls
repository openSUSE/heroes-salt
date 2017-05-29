{% set os_family = salt['grains.get']('os_family') %}
{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}

apparmor:
  pkg.installed:
    - pkgs:
        # SLE <= 12 and openSUSE <= 13.x don't have the separate apparmor-abstractions package
        # so install it everywhere except on those old SLE and openSUSE releases
        {% if os_family != 'Suse' or osmajorrelease >= 15 %}
        - apparmor-abstractions
        {% endif %}
        - apparmor-parser
        {% if salt['pillar.get']('apparmor:defaultprofiles', True) %}
        - apparmor-profiles
        {% endif %}
        - apparmor-utils

  service.running:
    - enable: True
    # restarting AppArmor means to remove confinement from running processes, so always use reload!
    - reload: True
