include:
  - profile.mirrorcache.packages
  - profile.mirrorcache.packages-hashes
  - profile.mirrorcache.env-conf

mirrorcache-backstage:
  service.running:
    - name: mirrorcache-backstage
    - enable: true

mirrorcache-backstage-hashes:
  service.running:
    - name: mirrorcache-backstage-hashes
    - enable: true

