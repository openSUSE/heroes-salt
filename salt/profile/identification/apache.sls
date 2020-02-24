{% set roles = salt['grains.get']('roles', []) %}

/etc/apache2/vhosts.d/id.opensuse.org.conf:
  file.managed:
    - listen_in:
      - service: apache2
    - source: salt://profile/identification/files/id.opensuse.org.conf
    - template: jinja
