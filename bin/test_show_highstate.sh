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
## in case of problems feel free to temporally enable line 18 and commend out line 16.
#RUN_TEST="salt-call --local --retcode-passthrough --log-level=debug state.show_highstate"

write_grains() {
    $SUDO sed -i -e "s/\(city:\).*/\1 $2/" -e "s/\(country:\).*/\1 $1/" -e "s/\(domain:\).*/\1 $5/" -e "s/\(virtual:\).*/\1 $3/" /etc/salt/grains
    echo_INFO "Grains: city: $2, country: $1, domain: $5, virtual: $3"
}

show_highstate() {
    local outfile="$domain.txt"
    write_grains $country $city $virtual $domain
    $RUN_TEST > "$outfile" 2>&1
    _STATUS=$?
    # We ignore exit code 2 as it means that an empty file is produced
    # See https://github.com/saltstack/salt/issues/39172
    if [[ $_STATUS -eq 0 ]] || [[ $_STATUS -eq 2 ]]; then
        echo_PASSED
    else
	cat /etc/salt/grains >> "$outfile"
	salt-call --local grains.get id >> "$outfile"
	salt-call --local grains.get domain >> "$outfile"
	salt-call --local grains.get virtual >> "$outfile"
	echo 'Dumping the last 100 log lines - the full output can be found in the CI artifacts'
	tail -n100 "$outfile"
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
    default_domain=$(bin/get_valid_custom_grains.py --default-domain $country)
    virtual='kvm'
    DOMAINS=( $(bin/get_valid_custom_grains.py -d $country) )
    for domain in ${DOMAINS[@]}; do
        show_highstate
    done
done

exit $STATUS
