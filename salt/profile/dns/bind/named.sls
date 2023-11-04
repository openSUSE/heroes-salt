bind_pgks:
  pkg.installed:
    - pkgs:
      - bind
      - bind-chrootenv
      - bind-utils
      - monitoring-plugins-bind9
