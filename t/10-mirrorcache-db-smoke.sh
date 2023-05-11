#!lib/test-in-container-systemd.sh mariadb

set -ex

ping -c1 download.infra.opensuse.org || echo 195.135.221.134 download.infra.opensuse.org >> /etc/hosts

salt-call --local state.apply 'role/mirrorcache-db-server'

rcmariadb status
test mirrorcache == $(mariadb --batch -Ne 'select database()' mirrorcache)

echo success
