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
    bin/test_${_test} || STATUS=1
done

exit $STATUS
