#!/bin/bash

# Run various code validation/syntax checks

TESTS=(
    extension.sh
    secrets.sh
    roles.py
    custom_grains.py
    show_highstate.sh
)

for _test in ${TESTS[@]}; do
    echo "Running test_${_test}"
    if bin/test_${_test}; then
        echo 'PASSED'
    else
        echo 'FAILED'
        STATUS=1
    fi
done

exit $STATUS
