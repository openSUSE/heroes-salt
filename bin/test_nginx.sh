#!/bin/bash

# Validate the salt-generated nginx configs

rpm -qa --qf '%{name}\n' | sort > /tmp/packages-before

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

# systemctl refuses to work in a container, but is needed by service.running. Replace it with /usr/bin/true to avoid useless error messages
( cd /usr/bin/ ; ln -sf true systemctl )

source bin/get_colors.sh

rpm -q nginx salt salt-master

IDFILE="pillar/id/$(hostname).sls"
IDFILE_BASE="$IDFILE.base.sls"
sed -i -e '/virtual/d' -e '/virt_cluster/d' /etc/salt/grains
cp "$IDFILE" "$IDFILE_BASE"

reset_nginx() {
    cp "$IDFILE_BASE" "$IDFILE"
    rm -rf /etc/nginx
    cp -a /etc/nginx_orig /etc/nginx
    printf "roles:\n- $role" >> "$IDFILE"
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

touch_includes() {
    case "$1" in
        mailman3)
            touch /etc/nginx/mails.rewritemap
            touch /etc/nginx/lists.rewritemap
            touch /etc/nginx/feeds.rewritemap
            touch /etc/nginx/mboxs.rewritemap
            touch /etc/nginx/miscs.rewritemap
            ;;
        pagure)
            touch /etc/nginx/acme-challenge
            mkdir -p /etc/ssl/services/letsencrypt
            cat test/fixtures/domain.{crt,key} > /etc/ssl/services/letsencrypt/code.opensuse.org.with.chain_rsa.pem
            cat test/fixtures/domain.{crt,key} > /etc/ssl/services/letsencrypt/code.opensuse.org.with.chain_ecdsa.pem
            sed '/ ssl_dhparam / d' -i /etc/nginx/ssl-config
            ;;
    esac;
}

cp -a /etc/nginx /etc/nginx_orig

WEB_ROLES=( $(bin/get_roles.py) )

for role in ${WEB_ROLES[@]}; do
    rolestatus=0
    sls_role="salt/role/${role/./\/}.sls"
    if grep nginx "$sls_role" > /dev/null; then
        echo_INFO "Testing role: $role"
        reset_nginx
        reset_ip
        if grep -q profile "$sls_role"
        then
            #for profile in "$(grep -h '\- profile' $sls_role | yq -o t)" // to-do: add yq to container
            for profile in $(grep -h '\- profile' $sls_role | sed 's/^\s\+ -//' | tr '\n' ' ')
            do
                if [ ! "$profile" == 'profile.web.server.nginx' ]
                then
                    dir_profile="${profile//./\/}"
                    if [ -f "salt/$dir_profile/nginx.sls" ]
                    then
                        state="$profile.nginx"
                    elif [ -f "salt/${dir_profile%/*}/nginx.sls" ]
                    then
                        state="${profile%.*}.nginx"
                    fi
                    if [ -n "$state" ]
                    then
                        salt-call --out=quiet --local state.apply "$state"
                        unset state
                        break
                    fi
                fi
            done
        fi
        salt-call --local state.apply nginx.ng > /dev/null
        create_fake_certs
        touch_includes $role

        # test config file syntax
        nginx -tq || rolestatus=1

        # make sure all vhost config files are named *.conf (without that suffix, they get ignored)
        for file in /etc/nginx/vhosts.d/* ; do
            test "$file" == "/etc/nginx/vhosts.d/*" && continue  # skip loop if no file exists in vhosts.d/
            echo "$file" | grep -q '\.conf$' || {
                echo "ERROR: $file is not named *.conf"
                rolestatus=1
            }
        done

        if test $rolestatus = 0; then
            echo_PASSED
        else
            echo_FAILED
            head -n1000 /etc/nginx/vhosts.d/*
            echo "### end of /etc/nginx/vhosts.d/* for role $role"
            STATUS=1
        fi
        echo
    fi
done

rpm -qa --qf '%{name}\n' | sort > /tmp/packages-after

diff -U0 /tmp/packages-before /tmp/packages-after || echo '=== The packages listed above were installed by one of the roles. Consider to add them to the docker image to speed up this test.'


exit $STATUS

vim:expandtab
