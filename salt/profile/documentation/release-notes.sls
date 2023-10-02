include:
  - profile.cron

relsync_packages:
  pkg.installed:
    - pkgs:
      - build # contains unrpm

relsync:
  user.present:
    - home: /home/relsync

{% set relsync_dirs = ['/home/relsync/bin', '/home/relsync/etc', '/srv/www/vhosts/doc.opensuse.org', '/srv/www/vhosts/doc.opensuse.org/release-notes'] %}

pinot_srv_www_vhosts_dir:
  file.directory:
    - name: /srv/www/vhosts

{% for dir in relsync_dirs %}
{{ dir }}:
  file.directory:
    - user: relsync
{% endfor %}

/etc/apache2/vhosts.d/002-doc.conf:
  file.managed:
    - mode: 755
    - source: salt://profile/documentation/files/002-doc.conf

/home/relsync/etc/releasenotes:
  file.managed:
    - mode: 755
    - source: salt://profile/documentation/files/releasenotes
    - user: relsync

/home/relsync/bin/update_release_notes:
  cron.present:
    - user: relsync
    - minute: 0
    - hour: "*/6"
  file.managed:
    - mode: 755
    - source: salt://profile/documentation/files/update_release_notes
    - user: relsync
