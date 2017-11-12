#!/bin/bash

# Prepares the CI runner environment to run the show_highstate tests

set -e

if [[ $(whoami) != 'root' ]]; then
    if [[ -f /usr/bin/sudo ]]; then
       SUDO='/usr/bin/sudo'
   else
       echo 'Please install sudo first, or run this script as root'
       exit 1
   fi
fi

$SUDO zypper -qn in --no-recommends salt git python3 python3-PyYAML
$SUDO rm -rf /srv/{salt,pillar}
$SUDO ln -s $PWD/salt /srv/salt
$SUDO ln -s $PWD/pillar /srv/pillar
echo 'domain: infra.opensuse.org' | $SUDO tee /etc/salt/grains > /dev/null
sed -i -e 's/^production:$/base:/' /srv/{salt,pillar}/top.sls
ROLES=$(bin/get_roles.py --yaml)
printf "city:\ncountry:\nsalt_cluster: opensuse\nvirt_cluster:\n$ROLES" > pillar/id/${HOSTNAME}.sls
