#!/bin/bash

# Runs state.show_highstate using all localized grains' combinations

if [[ $(whoami) != 'root' ]]; then
    if [[ -f /usr/bin/sudo ]]; then
        SUDO='/usr/bin/sudo'
    else
        echo 'Please install sudo first, or run this script as root'
        exit 1
    fi
fi

RUN_TEST="salt-call --local --retcode-passthrough state.show_highstate"
ALL_OS=(
    Leap,42,3
    SLES,11,4
    SLES,12,3
)
ALL_LOCATIONS=(
    nuremberg,de,atreju
    provo,us,bryce
)

write_grains() {
    $SUDO sed -i -e "s/\(city:\).*/\1 $1/" -e "s/\(country:\).*/\1 $2/" -e "s/\(osfullname:\).*/\1 $4/" -e "s/\(osmajorrelease:\).*/\1 $5/" \
        -e "s/\(osrelease_info:\).*/\1 [$5, $6]/" -e "s/\(virt_cluster:\).*/\1 $3/" /etc/salt/grains
    echo "Grains: osfullname: $4, osmajorrelease: $5, city: $1, country: $2, virt_cluster: $3"
}

for os in ${ALL_OS[@]}; do
    for location in ${ALL_LOCATIONS[@]}; do
        write_grains ${location//,/ } ${os//,/ }
        $RUN_TEST > /dev/null
        _STATUS=$(echo $?)
        if [[ $_STATUS -eq 0 ]] || [[ $_STATUS -eq 2 ]]; then
            echo 'PASSED'
        else
            STATUS=1
        fi
        echo
    done
done

exit $STATUS
