include:
  - profile.mirrorcache.packages
  - profile.mirrorcache.env-conf

mirrorcache:
  service.running:
    - name: mirrorcache-hypnotoad
    - enable: true
