#!lib/test-in-container-systemd.sh openSUSE:infrastructure:MirrorCache mariadb

set -ex

ping -c1 download.infra.opensuse.org || echo 195.135.221.134 download.infra.opensuse.org >> /etc/hosts

salt-call --local grains.setval roles '["mirrorcache-db-server","mirrorcache-webui","mirrorcache-backstage"]'

salt-call --local state.apply 'role/mirrorcache-db-server'
salt-call --local state.apply 'role/mirrorcache-webui'
salt-call --local state.apply 'role/mirrorcache-backstage'

curl -s 127.0.0.1:3000/update/?json | grep leap

echo success
