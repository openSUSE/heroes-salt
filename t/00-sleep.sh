#!lib/test-in-container-systemd.sh

set -ex

time sudo -u root ls

time salt-call --local cmd.run 'time sleep 1'

echo success
