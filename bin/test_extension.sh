#!/bin/bash

NON_SLS_PILLAR=$(find pillar -type f | grep -Ev "(/(macros|map)\.jinja|(FORMULAS|valid_custom_grains)\.yaml|\.sls)$|infra/(\w+\.yaml|schemas/\w+\.json)|/README\.md$")
NON_SLS_SALT=$(find salt -type f | grep -Ev "/(files|templates)/|(pillar\.example|\.sls|/README\.md)$|/(_grains|_modules|_runners|_states)/\w+\.py$")
NON_SLS=( ${NON_SLS_PILLAR} ${NON_SLS_SALT} )

if [[ -n "${NON_SLS[0]}" ]]; then
    echo "The following files are missing the .sls extension:"
    for file in "${NON_SLS[@]}"; do
        echo "${file}"
    done
    exit 1
fi
