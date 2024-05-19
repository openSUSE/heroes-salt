{%- set repodir = '/home/relsync/git/doc-o-o' %}

include:
  - profile.cron

relsync_packages:
  pkg.installed:
    - pkgs:
      - build # contains unrpm

relsync_user:
  user.present:
    - name: relsync
    - home: /home/relsync

/home/relsync/git:
  file.directory:
    - user: relsync

https://github.com/openSUSE/doc-o-o.git:
  git.cloned:
    - branch: main
    - target: {{ repodir }}
    - user: relsync
    - require:
        - user: relsync_user
        - file: /home/relsync/git

relsync_links:
  file.symlink:
    - names:
        - /home/relsync/bin/update_release_notes:
            - target: {{ repodir }}/rn-config/bin/update_release_notes
        - /home/relsync/etc:
            - target: {{ repodir }}/rn-config/etc
    - require:
        - git: https://github.com/openSUSE/doc-o-o.git

pinot_srv_www_vhosts_dir:
  file.directory:
    - name: /srv/www/vhosts

relsync_directories:
  file.directory:
    - names:
        - /srv/www/vhosts/doc.opensuse.org
        - /srv/www/vhosts/doc.opensuse.org/release-notes
    - user: relsync

/etc/apache2/vhosts.d/002-doc.conf:
  file.managed:
    - mode: '0755'
    - source: salt://profile/documentation/files/002-doc.conf

git -C {{ repodir }} pull -q && /home/relsync/bin/update_release_notes:
  cron.present:
    - user: relsync
    - minute: 0
    - hour: "*/6"
