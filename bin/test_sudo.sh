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

pushd pillar > /dev/null
SUDO_ROLES=(
    # Get all the roles that contain sudoers entries
    $(find role -type f -name '*.sls' -exec grep -l 'sudoers:' {} +)
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
