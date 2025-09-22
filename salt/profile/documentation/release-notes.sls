{%- set repodir = '/home/relsync/git/doc-o-o' %}
{%- set repodir_susern = '/home/relsync/git/release-notes' %}

include:
  - profile.cron

relsync_packages:
  pkg.installed:
    - pkgs:
      - build # contains unrpm
      - daps # building of SUSE's release-notes
      - make # building of SUSE's release-notes

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

https://github.com/SUSE/release-notes.git:
  git.cloned:
    - branch: main
    - target: {{ repodir_susern }}
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

# Legacy cronjob for original release notes
git -C {{ repodir }} pull -q && /home/relsync/bin/update_release_notes && rsync -a /home/relsync/release-notes/ /srv/www/vhosts/doc.opensuse.org/release-notes/:
  cron.present:
    - user: relsync
    - minute: 0
    - hour: "*/6"
    - identifier: update_rn

# Add new Leap RN versions here PRODUCT_VERSION: TARGET_RN_DIRNAME
{% set versions = {
  'leap-160': '16.0',
} %}

# For Leap 16.0 and newer
suse_rn_all_versions_cron:
  cron.present:
    - user: relsync
    - minute: 0
    - hour: "*/6"
    - identifier: suse_rn_all
    - name: >
        cd {{ repodir_susern }} &&
        git pull -q &&
        {% for buildname, pubdir in versions.items() %}
        make all PRODUCT_VERSION={{ buildname }} &&
        rsync -a --delete --exclude='log/' --exclude='DC-release-notes-*' {{ repodir_susern }}/build/release-notes-{{ buildname }}/ /srv/www/vhosts/doc.opensuse.org/release-notes/x86_64/openSUSE/Leap/{{ pubdir }}{% if not loop.last %} &&{% endif %}
        {% endfor %}
