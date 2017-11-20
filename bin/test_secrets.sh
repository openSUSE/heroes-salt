#!/bin/bash

# Script that validates that the pillar/secret/*/*.sls files contain the
# appropriate header, and that none other pillar files contain this header or
# any secrets

HEADER="#!yaml|gpg"

for secret_sls in $(find pillar/secrets -name '*.sls'); do
    if [[ $(head -n 1 $secret_sls) != "$HEADER" ]]; then
        echo "$secret_sls is missing the \"$HEADER\" header or it is not on the first line"
        STATUS=1
    fi
done

for sls in $(find pillar/ -not -path 'pillar/secrets/*' -name '*.sls'); do
    if $(grep -q "$HEADER" $sls); then
        echo "$sls has the \"$HEADER\" header, please remove it"
        STATUS=1
    fi
    if $(grep -q "BEGIN GPG MESSAGE" $sls); then
        echo "$sls contains secrets. Please move them to pillar/secrets/${sls#*/}"
        STATUS=1
    fi
done

exit $STATUS
