include:
  - profile.udev.net
  - .common
  - libvirt.guests

extend:
  /etc/udev/rules.d/80-salt-net.rules:
    file:
      - require_in:
          - sls: infrastructure.libvirt.domains
