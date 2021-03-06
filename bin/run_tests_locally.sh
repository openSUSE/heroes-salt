#!/bin/bash

help() {
    echo "Runs all the tests on the user's workstation."
    echo "Needs to be run as normal user."
    echo
    echo "Arguments:"
    echo "-d <DESTINATION>  Absolute path of the destination directory where the formulas are / should be cloned"
    echo
}

[[ $(whoami) == 'root' ]] && help && exit 1

[[ $1 == '--help' ]] && help && exit

while getopts d:h arg; do
    case ${arg} in
        d) DESTINATION=${OPTARG} ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

[[ -z $DESTINATION ]] && help && exit 1

SALT_DIRS=(
    /etc/salt
    /var/log/salt
    /var/cache/salt
)

# Prepare env
for dir in ${SALT_DIRS[@]}; do
    sudo chown -R ${USER}: $dir
done
bin/prepare_test_env.sh -g -s
bin/get_formulas.py --destination $DESTINATION --clone --symlink --update opensuse \
    --add-remote opensuse no_prefix gitlab@gitlab.infra.opensuse.org: saltstack-formulas
ln -s ~/.gnupg /etc/salt/gpgkeys

# Run tests
echo "Running against upstream formulas"
LC_ALL=C bin/test_validate.sh
bin/get_formulas.py --destination $DESTINATION --checkout opensuse/production
echo "Running against forked formulas"
LC_ALL=C bin/test_show_highstate.sh

# Cleanup
bin/get_formulas.py --destination $DESTINATION --remove-symlinks --checkout origin/master
for dir in ${SALT_DIRS[@]}; do
    sudo chown -R root: $dir
done
sudo rm /srv/{salt,pillar} /etc/salt/{grains,gpgkeys}
sudo mkdir /srv/{salt,pillar}
ID=$(hostname -f)
rm pillar/id/${ID//./_}.sls
