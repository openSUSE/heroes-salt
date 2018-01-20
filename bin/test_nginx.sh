#!/bin/bash

# Validate the salt-generated nginx configs

if [[ $(whoami) != 'root' ]]; then
    if [[ -f /usr/bin/sudo ]]; then
        SUDO='/usr/bin/sudo'
    else
        echo 'Please install sudo first, or run this script as root'
        exit 1
    fi
fi

reset_nginx() {
    $SUDO rm -rf /etc/nginx/vhosts.d/*
    printf "roles:\n- $role" | $SUDO tee /etc/salt/grains > /dev/null
}

WEB_ROLES=( $(bin/get_roles.py | grep web_) )

for role in ${WEB_ROLES[@]}; do
    if grep nginx salt/role/$role.sls > /dev/null; then
        echo "Testing role: $role"
        reset_nginx
        $SUDO salt-call --local -l quiet state.apply role.$role > /dev/null
        if $(nginx -tq); then
            echo 'PASSED'
        else
            STATUS=1
        fi
    fi
done

exit $STATUS
