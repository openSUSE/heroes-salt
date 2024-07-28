include:
  - profile.docroot

OOMAnalyser:
  pkg.installed

link_oom_vhost:
  file.symlink:
    - name: /srv/www/vhosts/oom.opensuse.org
    - target: /srv/www/OOMAnalyser
    - require:
      - file: /srv/www/vhosts/
