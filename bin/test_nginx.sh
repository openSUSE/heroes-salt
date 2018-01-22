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
    rm -rf /etc/nginx
    cp -a /etc/nginx_orig /etc/nginx
    printf "roles:\n- $role" | $SUDO tee /etc/salt/grains > /dev/null
}

reset_ip() {
    # Reset the grains-retrieved IPs to 127.0.0.1, as `nginx -t` actually tries
    # to bind to any configured listen IP

    sed -i -e "s/{{ ip4_.* }}/127.0.0.1/g" pillar/role/$role.sls
}

create_fake_certs() {
    # We are replacing both the cert/key pair because:
    # - the key is encrypted and the CI worker can't decrypt it
    # - the nginx validation command tries to match the pair

    PRIVATE_KEYS=( $(grep ssl_certificate_key pillar/role/$role.sls | cut -d':' -f2) )
    for key in ${PRIVATE_KEYS[@]}; do
        if [[ ${key##*.} != 'key' ]]; then
            echo "pillar/role/$role.sls \"ssl_certificate_key: $key\" should have extension .key"
            STATUS=1
        else
            $SUDO cp test/fixtures/domain.key $key
        fi
    done

    PUBLIC_CERTS=( $(grep "ssl_certificate:" pillar/role/$role.sls | cut -d':' -f2) )
    for cert in ${PUBLIC_CERTS[@]}; do
        if [[ ${cert##*.} != 'crt' ]]; then
            echo "pillar/role/$role.sls \"ssl_certificate: $cert\" should have extension .crt"
            STATUS=1
        else
            $SUDO cp test/fixtures/domain.crt $cert
        fi
    done
}

WEB_ROLES=( $(bin/get_roles.py | grep web_) )

for role in ${WEB_ROLES[@]}; do
    if grep nginx salt/role/$role.sls > /dev/null; then
        echo "Testing role: $role"
        reset_nginx
        reset_ip
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