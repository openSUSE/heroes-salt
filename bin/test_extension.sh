#!/bin/bash

NON_SLS_PILLAR=$(find pillar -type f | egrep -v "(macros.jinja|(FORMULAS|valid_custom_grains).yaml|\.sls$)")
NON_SLS_SALT=$(find salt -type f | egrep -v "/(files|templates)/|pillar.example$|\.sls$")
NON_SLS=( ${NON_SLS_PILLAR} ${NON_SLS_SALT} )

if [[ -n $NON_SLS ]]; then
    echo "The following files are missing the .sls extension:"
    for file in ${NON_SLS[@]}; do
        echo ${file}
    done
    exit 1
fi
