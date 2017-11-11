#!/bin/bash

help() {
    echo "Encrypt a given string and print out the output. This output can be"
    echo "then used as encrypted pillar"
    echo
}

[[ $1 == '--help' ]] && help && exit

while getopts h arg; do
    case ${arg} in
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

echo "Please type the string that you want to encrypt"
read STRING

[[ -z $STRING ]] && help && exit 1

RECIPIENTS=$(egrep '^\s*0x' encrypted_pillar_recipients | while read i; do echo "-r $i"; done | xargs)
echo -n "${STRING}" | gpg --armor --batch --trust-model always --encrypt ${RECIPIENTS}
