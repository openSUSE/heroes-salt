#!/bin/bash

help() {
    echo "Encrypt a given string and print out the output. This output can be"
    echo "then used as encrypted pillar"
    echo
    echo "Arguments:"
    echo "-s STRING   The string to encrypt"
    echo
}

[[ $1 == '--help' ]] && help && exit

while getopts s:v:h arg; do
    case ${arg} in
        s) STRING=${OPTARG} ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

[[ -z $STRING ]] && help && exit 1

RECIPIENTS=$(egrep '^\s*0x' encrypted_pillar_recipients | while read i; do echo "-r $i"; done | xargs)
echo -n "${STRING}" | gpg --armor --batch --trust-model always --encrypt ${RECIPIENTS}
