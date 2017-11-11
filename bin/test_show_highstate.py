#!/bin/bash

# Runs state.show_highstate using all localized grains' combinations

set -e

RUN_TEST="salt-call --local --retcode-passthrough state.show_highstate"
ROLES=$(bin/get_roles.py --yaml)

echo 'domain: infra.opensuse.org' > /etc/salt/grains
printf "city:\ncountry:\nsalt_cluster: opensuse\nvirt_cluster:\n$ROLES" > pillar/id/${HOSTNAME}.sls

sed -i -e 's/\(city:\).*/\1 nuremberg/' -e 's/\(country:\).*/\1 de/' -e 's/\(virt_cluster:\).*/\1 atreju/'  pillar/id/${HOSTNAME}.sls
$RUN_TEST > /dev/null
echo "PASSED: country: de"

sed -i -e 's/\(city:\).*/\1 provo/' -e 's/\(country:\).*/\1 us/' -e 's/\(virt_cluster:\).*/\1 bryce/'  pillar/id/${HOSTNAME}.sls
$RUN_TEST > /dev/null
echo "PASSED: country: us"
