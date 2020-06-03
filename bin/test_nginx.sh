#!/bin/bash

# Validate the salt-generated nginx configs

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

source bin/get_colors.sh

reset_nginx() {
    rm -rf /etc/nginx
    cp -a /etc/nginx_orig /etc/nginx
    printf "roles:\n- $role" > /etc/salt/grains
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
            cp test/fixtures/domain.key $key
        fi
    done

    PUBLIC_CERTS=( $(grep "ssl_certificate:" pillar/role/$role.sls | cut -d':' -f2) )
    for cert in ${PUBLIC_CERTS[@]}; do
        if [[ ${cert##*.} != 'crt' ]]; then
            echo "pillar/role/$role.sls \"ssl_certificate: $cert\" should have extension .crt"
            STATUS=1
        else
            cp test/fixtures/domain.crt $cert
        fi
    done
}

cp -a /etc/nginx /etc/nginx_orig

WEB_ROLES=( $(bin/get_roles.py) )

for role in ${WEB_ROLES[@]}; do
    if grep nginx salt/role/$role.sls > /dev/null; then
        echo_INFO "Testing role: $role"
        reset_nginx
        reset_ip
        salt-call --local -l quiet state.apply role.$role > /dev/null
        create_fake_certs
        if $(nginx -tq); then
            echo_PASSED
        else
            echo_FAILED
            STATUS=1
        fi
        echo
    fi
done

exit $STATUS
