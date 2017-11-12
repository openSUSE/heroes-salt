#!/bin/bash

# Prepares the CI runner environment to run the show_highstate tests

zypper -qn in --no-recommends salt git python3 python3-PyYAML
rm -rf /srv/{salt,pillar}
ln -s $PWD/salt /srv/salt
ln -s $PWD/pillar /srv/pillar
sed -i -e 's/^production:$/base:/' /srv/{salt,pillar}/top.sls
echo 'domain: infra.opensuse.org' > /etc/salt/grains
ROLES=$(bin/get_roles.py --yaml)
printf "city:\ncountry:\nsalt_cluster: opensuse\nvirt_cluster:\n$ROLES" > pillar/id/${HOSTNAME}.sls
