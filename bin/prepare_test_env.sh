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
    echo "-g             Make preparation for show_highstate"
    echo "-s             Include secrets files (disabed because CI runner can't decrypt them due to lack of GPG key)"
    echo
}

[[ $1 == '--help' ]] && help && exit

SECRETS="False"

while getopts p:gsh arg; do
    case ${arg} in
        p) PKG=(${OPTARG//,/ }) ;;
        g) HIGHSTATE=1 ;;
        s) SECRETS="True" ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

[[ -n $HIGHSTATE ]] && HIGHSTATE_PKGS=( git python3-PyYAML )

$SUDO zypper -qn in --no-recommends salt ${HIGHSTATE_PKGS[@]} ${PKG[@]}
$SUDO rm -rf /srv/{salt,pillar}
$SUDO ln -s $PWD/salt /srv/salt
$SUDO ln -s $PWD/pillar /srv/pillar
ID=$(hostname -f)
printf "grains:\n  city: nuremberg\n  country: de\n  hostusage: test\n  salt_cluster: opensuse\n  virt_cluster: atreju\n" > pillar/id/${ID//./_}.sls
if [[ -n $HIGHSTATE ]]; then
    ROLES=$(bin/get_roles.py -o yaml)
    printf "city:\ncountry:\ndomain: infra.opensuse.org\ninclude_secrets: $SECRETS\nosfullname:\nosmajorrelease:\nosrelease_info:\n$ROLES\nsalt_cluster: opensuse\nvirt_cluster:\nvirtual:\n" > /etc/salt/grains
fi
