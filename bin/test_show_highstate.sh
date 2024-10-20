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

RUN_TEST='salt-call --local --retcode-passthrough state.show_highstate'
STATUS=0

write_grains() {
    $SUDO sed -i -e "s/\(site:\).*/\1 $1/" -e "s/\(domain:\).*/\1 $2/" -e "s/\(virtual:\).*/\1 $3/" /etc/salt/grains
    echo_INFO "Grains: site: $1, domain: $2, virtual: $3"
}

show_highstate() {
    local domain="$2"
    local outfile="$domain.txt"
    write_grains "$1" "$domain" "$3"
    $RUN_TEST > "$outfile" 2>&1
    _STATUS=$?
    # We ignore exit code 2 as it means that an empty file is produced
    # See https://github.com/saltstack/salt/issues/39172
    if [[ $_STATUS -eq 0 ]] || [[ $_STATUS -eq 2 ]]; then
        echo_PASSED
    else
      {
        cat /etc/salt/grains
        salt-call --local grains.get id
        salt-call --local grains.get domain
        salt-call --local grains.get virtual
      } >> "$outfile"
      echo 'Dumping the last 100 log lines - the full output can be found in the CI artifacts'
      tail -n100 "$outfile"
      echo_FAILED
      STATUS=1
    fi
    echo
}

ALL_LOCATIONS=( $(bin/get_valid_custom_grains.py) )
for site in "${ALL_LOCATIONS[@]}"; do
    show_highstate "$site" 'infra.opensuse.org' 'kvm'
done

exit "$STATUS"
