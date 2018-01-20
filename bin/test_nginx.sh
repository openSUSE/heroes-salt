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

create_fake_certs() {
    # We are replacing both the cert/key pair because:
    # - the key is encrypted and the CI worker can't decrypt it
    # - the nginx validation command tries to match the pair

    PRIVATE_KEYS=( $(grep ssl_certificate_key pillar/role/$role.sls | cut -d':' -f2) )
    for key in ${PRIVATE_KEYS[@]}; do
        $SUDO cp test/fixtures/domain.key $key
    done

    PUBLIC_CERTS=( $(grep "ssl_certificate:" pillar/role/$role.sls | cut -d':' -f2) )
    for cert in ${PUBLIC_CERTS[@]}; do
        $SUDO cp test/fixtures/domain.crt $cert
    done
}


WEB_ROLES=( $(bin/get_roles.py | grep web_) )

for role in ${WEB_ROLES[@]}; do
    if grep nginx salt/role/$role.sls > /dev/null; then
        echo "Testing role: $role"
        reset_nginx
        $SUDO salt-call --local -l quiet state.apply role.$role > /dev/null
        create_fake_certs
        if $(nginx -tq); then
            echo 'PASSED'
        else
            STATUS=1
        fi
    fi
done

exit $STATUS
