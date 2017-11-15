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
ID=$(hostname -f)
ROLES=$(bin/get_roles.py --yaml)
printf "city:\ncountry:\ndomain: infra.opensuse.org\nosfullname:\nosmajorrelease:\nosrelease_info:\n$ROLES\nsalt_cluster: opensuse\nvirt_cluster:" | $SUDO tee /etc/salt/grains > /dev/null
sed -i -e 's/^production:$/base:/' /srv/{salt,pillar}/top.sls
touch pillar/id/${ID//./_}.sls
sed -i -e "s#\- secrets\..*#- id.${ID//./_}#g" $(grep -lr "\- secrets\.")
