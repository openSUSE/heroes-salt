#!/bin/bash

# See the description at the help()

set -e

if [[ $(whoami) != 'root' ]]; then
    if [[ -f /usr/bin/sudo ]]; then
        SUDO='/usr/bin/sudo'
    else
        echo 'Please install sudo first, or run this script as root'
        exit 1
    fi
fi

help() {
    echo "Prepares the CI runner or workstation environment to run highstate or show_highstate tests"
    echo
    echo "Arguments:"
    echo
    echo "-p <pkg1,pkg2> Comma-separated list of additional packages to be installed"
    echo "-s             Strip out secrets files (CI runner can't read them)"
    echo
}

[[ $1 == '--help' ]] && help && exit

while getopts p:sh arg; do
    case ${arg} in
        p) PKG=(${OPTARG//,/ }) ;;
        s) STRIP_SECRETS=1 ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

$SUDO zypper -qn in --no-recommends salt git python3 python3-PyYAML ${PKG}
$SUDO rm -rf /srv/{salt,pillar}
$SUDO ln -s $PWD/salt /srv/salt
$SUDO ln -s $PWD/pillar /srv/pillar
ID=$(hostname -f)
ROLES=$(bin/get_roles.py -o yaml)
printf "city:\ncountry:\ndomain: infra.opensuse.org\nosfullname:\nosmajorrelease:\nosrelease_info:\n$ROLES\nsalt_cluster: opensuse\nvirt_cluster:\n" | $SUDO tee /etc/salt/grains > /dev/null
printf "grains:\n  city: nuremberg\n  country: de\n  hostusage: test\n  salt_cluster: opensuse\n  virt_cluster: atreju\n" > pillar/id/${ID//./_}.sls
[[ -n $STRIP_SECRETS ]] && sed -i -e "s#\- secrets\..*#- id.${ID//./_}#g" $(grep -lr "\- secrets\." pillar)
