include:
  - zypper

packages:
  pkg.installed:
    - refresh: False
    - pkgs:
      - MirrorCache
      - perl-Mojo-mysql
      - perl-Minion-Backend-mysql
      - perl-DateTime-Format-MySQL

packages-geofeature:
  pkg.installed:
    - refresh: False
    - unless: test ! -f /var/lib/GeoIP/GeoLite2-City.mmdb
    - pkgs:
      - perl-Mojolicious-Plugin-ClientIP
      - perl-MaxMind-DB-Reader
