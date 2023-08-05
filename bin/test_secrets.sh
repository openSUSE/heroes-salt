#!/bin/bash

# Script that validates that the pillar/secret/*/*.sls files contain the
# appropriate header, and that none other pillar files contain this header or
# any secrets

set -Ceu

HEADER_REGEX='^(#!yaml\|gpg|#!gpg\|yaml)$'
HEADER_EMPTY='^(# empty)$'
STATUS=0

SECRETS_SLS=$(find pillar/secrets -name '*.sls' 2> /dev/null)
if [[ -n $SECRETS_SLS ]];  then
    for secret_sls in ${SECRETS_SLS[@]}; do
        HEADER_LINE="$(head -n 1 $secret_sls)"
	if [[ ! "$HEADER_LINE" =~ $HEADER_REGEX && ! ( "$HEADER_LINE" =~ $HEADER_EMPTY && "$(wc -l < $secret_sls)" == 1 ) ]]; then
            echo "The first line in $secret_sls is not matching \"$HEADER_REGEX\""
            STATUS=1
        fi
    done
fi

for sls in $(find pillar/ -not -path 'pillar/secrets/*' -name '*.sls'); do
    if $(grep -Eq "$HEADER_REGEX" $sls); then
        echo "$sls matches \"$HEADER_REGEX\", please remove such lines from non-secret pillar files"
        STATUS=1
    fi
    if $(grep -q "BEGIN GPG MESSAGE" $sls); then
        echo "$sls contains secrets. Please move them to pillar/secrets/${sls#*/}"
        STATUS=1
    fi
done

exit $STATUS
