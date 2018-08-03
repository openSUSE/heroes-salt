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
PHYSICAL_ONLY_VIRT_CLUSTER=( $(bin/get_valid_custom_grains.py -p) )

write_grains() {
    $SUDO sed -i -e "s/\(city:\).*/\1 $2/" -e "s/\(country:\).*/\1 $1/" -e "s/\(domain:\).*/\1 $5/" -e "s/\(virt_cluster:\).*/\1 $3/" -e "s/\(virtual:\).*/\1 $4/" /etc/salt/grains
    echo_INFO "Grains: city: $2, country: $1, domain: $5, virt_cluster: $3, virtual: $4"
}

show_highstate() {
    write_grains $country $city $virt_cluster $virtual $domain
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
}

ALL_LOCATIONS=( $(bin/get_valid_custom_grains.py) )
for location in ${ALL_LOCATIONS[@]}; do
    LOCATION=(${location//,/ })
    country=${LOCATION[0]}
    city=${LOCATION[1]}
    virt_cluster=${LOCATION[2]}
    domain=$(bin/get_valid_custom_grains.py --default-domain $country)
    for virtual in ${ALL_VIRTUAL[@]}; do
        if [[ $virtual == 'kvm' ]] && [[ ${PHYSICAL_ONLY_VIRT_CLUSTER[@]} =~ $virt_cluster ]]; then
            continue
        fi
        show_highstate
    done
done

ALL_LOCATIONS=( $(bin/get_valid_custom_grains.py -v) )
for location in ${ALL_LOCATIONS[@]}; do
    LOCATION=(${location//,/ })
    country=${LOCATION[0]}
    city=${LOCATION[1]}
    virt_cluster=${LOCATION[2]}
    default_domain=$(bin/get_valid_custom_grains.py --default-domain $country)
    virtual='kvm'
    DOMAINS=( $(bin/get_valid_custom_grains.py -d $country) )
    for domain in ${DOMAINS[@]}; do
        [[ $domain == $default_domain ]] || show_highstate
    done
done

exit $STATUS
