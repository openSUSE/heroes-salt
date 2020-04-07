/etc/apache2/vhosts.d/sso.opensuse.org.conf:
  file.managed:
    - listen_in:
      - service: apache2
    - source: salt://profile/identification/files/sso.opensuse.org.conf
    - template: jinja
