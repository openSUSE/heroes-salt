#!/bin/bash

# Validate the salt-generated sudo configs

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

source bin/get_colors.sh

reset_sudo() {
    rm -rf /etc/sudoers*
    cp -a /etc/orig/* /etc
    printf "roles:\n- $role" > /etc/salt/grains
}

mkdir /etc/orig
cp -a /etc/sudoers* /etc/orig

run_tests() {
    salt-call --local -l quiet state.apply sudoers,sudoers.included > /dev/null
    visudo -c > output 2>&1
    STATUS=$?
    if [[ $STATUS == 0 ]]; then
        echo_PASSED
    else
        cat output
        echo_FAILED
    fi
    echo
    return $STATUS
}

echo_INFO "Testing virtual: physical"
echo "virtual: physical" > /etc/salt/grains
run_tests

pushd pillar > /dev/null
SUDO_ROLES=(
    # Get all the roles that include common sls files, which contain sudoers entries
    $(grep -lr 'sudoers:' role/common/ | while read i; do L=${i%%.*}; L=${L//\//.}; grep -lr $L role/*.sls; done)
    # Get all the roles that contain sudoers entries
    $(grep -lr 'sudoers:' role/*.sls)
    # add additional roles that contain sudoers rules and are difficult to find in an automated way
    role/worker_gitlab.sls
)
popd > /dev/null

ALL_STATUS=0

for _role in ${SUDO_ROLES[@]}; do
    _role=${_role##*/}
    role=${_role%%.*}
    echo_INFO "Testing role: $role"
    reset_sudo
    run_tests || ALL_STATUS=$?
done

exit $ALL_STATUS
