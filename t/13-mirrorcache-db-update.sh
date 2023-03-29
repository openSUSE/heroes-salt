#!lib/test-in-container-systemd.sh openSUSE:infrastructure:MirrorCache mariadb

set -ex

ping -c1 download.infra.opensuse.org || echo 195.135.221.134 download.infra.opensuse.org >> /etc/hosts

salt-call --local grains.setval roles '["test-mysql-server","mirrorcache-db-server","mirrorcache-webui","mirrorcache-backstage"]'

PASS=mypass12

# package might be already installed
mariadb --version || zypper -n in mariadb
rcmariadb start
mariadb -e 'create database mirrorcache'
mariadb -e "create user mirrorcache@localhost identified by '$PASS'"
mariadb -e "grant all on mirrorcache.* to mirrorcache@localhost; flush privileges;"

mariadb -h 127.0.0.1 -umirrorcache -p$PASS -e 'select user(), current_user(), database()' mirrorcache

# hack the pillar
echo "
mysql:
  user:
    mirrorcache:
      password: $PASS
" > /srv/pillar/role/test-mysql-server.sls

echo skipping salt-call --local state.apply 'role/mirrorcache-db-server'
salt-call --local state.apply 'role/mirrorcache-webui'
salt-call --local state.apply 'role/mirrorcache-backstage'

curl -s 127.0.0.1:3000/update/?json | grep leap

rcmirrorcache-hypnotoad stop

echo apply now apply states again and make sure the serice survives
salt-call --local state.apply 'role/mirrorcache-db-server'
salt-call --local state.apply 'role/mirrorcache-webui'

curl -s 127.0.0.1:3000/update/?json | grep leap

echo success
