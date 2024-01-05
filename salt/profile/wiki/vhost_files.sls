#
# files.opensuse.org - several redirects and ~600 MB real, old files
#

/srv/www/files.opensuse.org/public:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True

/etc/apache2/vhosts.d/files.opensuse.org.conf:
  file.managed:
    - listen_in:
      - service: apache2
    - source: salt://profile/wiki/files/apache-vhost-files.conf
