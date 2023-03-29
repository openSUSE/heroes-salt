#!lib/test-in-container-systemd.sh mariadb

set -ex

salt-call --local grains.setval role mysql
salt-call --local state.apply 'profile/mysql/server'

mysql -e 'select user(), current_user(), version()'

rcmariadb status

echo success
