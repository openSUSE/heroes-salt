#!lib/test-in-container-systemd.sh

set -ex

salt-call --local slsutil.renderer $PWD/pillar/secrets/mirrorcache.sls

echo success
