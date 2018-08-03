#!/bin/bash

# Runs state.show_highstate using all localized grains' combinations

source bin/get_colors.sh

if [[ $(whoami) != 'root' ]]; then
    if [[ -f /usr/bin/sudo ]]; then
        SUDO='/usr/bin/sudo'
    else
        echo 'Please install sudo first, or run this script as root'
        exit 1
    fi
fi

RUN_TEST="salt-call --local --retcode-passthrough state.show_highstate"
ALL_VIRTUAL=(
    kvm
)
ALL_LOCATIONS=( $(bin/get_valid_custom_grains.py) )

write_grains() {
    $SUDO sed -i -e "s/\(city:\).*/\1 $2/" -e "s/\(country:\).*/\1 $1/" -e "s/\(virt_cluster:\).*/\1 $3/" -e "s/\(virtual:\).*/\1 $4/" /etc/salt/grains
    echo_INFO "Grains: city: $2, country: $1, virt_cluster: $3, virtual: $4"
}

for location in ${ALL_LOCATIONS[@]}; do
    for virtual in ${ALL_VIRTUAL[@]}; do
        write_grains ${location//,/ } ${virtual}
        $RUN_TEST > /dev/null
        _STATUS=$(echo $?)
        # We ignore exit code 2 as it means that an empty file is produced
        # See https://github.com/saltstack/salt/issues/39172
        if [[ $_STATUS -eq 0 ]] || [[ $_STATUS -eq 2 ]]; then
            echo_PASSED
        else
            echo_FAILED
            STATUS=1
        fi
        echo
    done
done

exit $STATUS
