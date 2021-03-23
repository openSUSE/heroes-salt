#!/bin/bash

# See the description at the help()

set -e
set -x
if [ ! -r /etc/os-release ]; then
    echo "Could not read /etc/os-release - exiting" >&2
    exit 1
fi
source /etc/os-release
SECRETS="False"
REPO_URL=${PRETTY_NAME// /_}
PKG=''
INSTANCE='opensuse'

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
    echo "-p <pkg1,pkg2> Comma-separated list of additional packages to be installed"
    echo "-i <instance>  Choose gitlab instance. Choices: opensuse, suse"
    echo "-o <OS>        OPTIONAL: Specify different OS. Examples: \"Leap,42,3\", \"SLES,12,3\""
    echo "-g             OPTIONAL: Make preparation for show_highstate"
    echo "-s             OPTIONAL: Include secrets files (disabed because CI runner can't decrypt them due to lack of GPG key)"
    echo
}

[[ $1 == '--help' ]] && help && exit

while getopts p:i:o:gsh arg; do
    case ${arg} in
        p) PKG=(${OPTARG//,/ }) ;;
        i) INSTANCE=${OPTARG} ;;
        o) OS=(${OPTARG//,/ }) ;;
        g) HIGHSTATE=1 ;;
        s) SECRETS="True" ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

[[ -z "$INSTANCE" ]] && help && exit 1
[[ -n "$HIGHSTATE" ]] && HIGHSTATE_PKGS=( git-core python3-PyYAML )

if [[ "$INSTANCE" == 'opensuse' ]]; then
    DOMAIN='infra.opensuse.org'
    SALT_CLUSTER='opensuse'
    VIRT_CLUSTER='atreju'
fi

if [ -n "${PKG[@]}" ]; then
    $SUDO zypper --gpg-auto-import-keys ref
    $SUDO zypper -qn install --no-recommends ${PKG[@]}
fi

$SUDO rm -rf /srv/{salt,pillar} 2>/dev/null
$SUDO ln -s $PWD/salt /srv/salt
$SUDO ln -s $PWD/pillar /srv/pillar
ID=$(hostname -f)

printf "grains:\n  city: nuremberg\n  country: de\n  hostusage: test\n  reboot_safe: no\n  salt_cluster: $SALT_CLUSTER\n  virt_cluster: $VIRT_CLUSTER\n" > pillar/id/${ID//./_}.sls

if [[ -n "$HIGHSTATE" ]]; then
    ROLES=$(bin/get_roles.py -o yaml)
    [[ -n "$OS" ]] && OS_GRAINS="osfullname: ${OS[0]}\nosmajorrelease: ${OS[1]}\nosrelease_info: [${OS[1]}, ${OS[2]}]\n"
    printf "city:\ncountry:\ndomain: $DOMAIN\ninclude_secrets: $SECRETS\n$OS_GRAINS$ROLES\nsalt_cluster: $SALT_CLUSTER\nvirt_cluster:\nvirtual:\n" > /etc/salt/grains
fi
