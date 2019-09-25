countdown_packages:
  pkg.installed:
    - pkgs:
      - adobe-sourcesanspro-fonts
      - git
      - google-opensans-fonts
      - inkscape
      - optipng
      - rsync

countdown:
  user.present:
    - fullname: countdown.o.o
    - home: /srv/www/countdown.opensuse.org

{% set countdown_dirs = ['/srv/www/countdown.opensuse.org', '/srv/www/countdown.opensuse.org/output', '/srv/www/countdown.opensuse.org/public'] %}

{% for dir in countdown_dirs %}
{{ dir }}:
  file.directory:
    - user: countdown
{% endfor %}

/etc/cron.d/countdown.opensuse.org:
  file.managed:
    - contents:
      - '0 * * * *     countdown   /srv/www/countdown.opensuse.org/svg/cron.sh -G -E && rsync -a --delete-after /srv/www/countdown.opensuse.org/output/ /srv/www/countdown.opensuse.org/public/'

cron:
  service.running:
    - enable: True

countdown_git:
  git.latest:
    - name: https://github.com/openSUSE/countdown.o.o.git
    - target: /srv/www/countdown.opensuse.org/git
    - user: countdown
    - force_reset: True
    - require:
      - pkg: countdown_packages

# TODO (after Leap 15 release?): change path in countdown.o.o cron.sh and get rid of these symlinks
/home/counter.opensuse.org:
  file.symlink:
    - target: /srv/www/countdown.opensuse.org

/srv/www/countdown.opensuse.org/svg:
  file.symlink:
    - target: /srv/www/countdown.opensuse.org/git