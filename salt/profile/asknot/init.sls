asknot_packages:
  pkg.installed:
    - pkgs:
      - asknot-ng

/etc/apache2/vhosts.d/contribute.opensuse.org.conf:
  file.managed:
    - mode: 644
    - source: salt://profile/asknot/files/apache-vhost.conf
