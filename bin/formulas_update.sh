#!/bin/bash

# WARNING: This is a nasty script that needs to be unhardcoded before used

FORMULAS=(
    dhcpd
    grains
    keepalived
    limits
    locale
    mysql
    ntp
    openssh
    powerdns
    salt
    sqlite
    sssd
    sudoers
    timezone
    users
    zypper
)

for formula in ${FORMULAS[@]}; do
    echo "### $formula"
    case $formula in
        grains|sqlite|zypper) owner=tampakrap ;;
        limits) owner=ryancurrah ;;
        sssd)
            owner=Spark-Networks
            prefix=salt-
            ;;
        *) owner=saltstack-formulas ;;
    esac
    upstream=git://github.com/$owner/$prefix$formula-formula
    [[ -d $formula-formula ]] || git clone $upstream
    pushd $formula-formula > /dev/null
    git remote set-url origin ${upstream}.git
    git remote remove opensuse
    git remote remove tampakrap
    git remote add opensuse gitlab@gitlab.infra.opensuse.org:saltstack-formulas/$formula-formula.git
    git remote add tampakrap git@github.com:tampakrap/$prefix$formula-formula.git
    git remote -v
    git checkout master
    git fetch origin
    git reset --hard origin/master
    git push -f opensuse master
    git push -f opensuse master:production
    popd > /dev/null
done
