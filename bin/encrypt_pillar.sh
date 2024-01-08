#!/bin/bash

set -Cef

help() {
    echo "Encrypt a given string and print out the output. This output can be"
    echo "then used as encrypted pillar"
    echo
    echo "Options:"
    echo "-m        Pass multiline input, end with CTRL+D when done"
    echo
}

[[ "$1" == '--help' ]] && help && exit

set -u
MULTILINE=0

while getopts mh arg; do
    case ${arg} in
        m) MULTILINE=1 ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

if [[ "$MULTILINE" = 1 ]]; then
    [ -t 0 ] && echo "Please type the lines that you want to encrypt, and press CTRL+D when done:" >/dev/stderr
    STRING=$(cat)
else
    [ -t 0 ] && echo "Please type the string that you want to encrypt:" >/dev/stderr
    read STRING
fi

[[ -z $STRING ]] && echo "ERROR: Input was empty" >/dev/stderr && exit 1

RECIPIENTS=( $(grep -E '^\s*0x' encrypted_pillar_recipients | while read i; do echo "-r $i"; done | xargs) )
echo -n "${STRING}" | gpg --armor --batch --trust-model always --encrypt "${RECIPIENTS[@]}"
