#!/bin/bash
OUTPUT=$(mktemp /tmp/$(basename $0)-XXXXXX) || exit 1;

sudo logrotate --debug /etc/logrotate.conf 1>$OUTPUT 2>&1
if [ $? != 0 ]; then
    echo 
    echo "There is an error in one or more logrotate snipplets" >&2
    echo
    cat "$OUTPUT"
    rm "$OUTPUT"
    exit 1
fi
rm "$OUTPUT"
