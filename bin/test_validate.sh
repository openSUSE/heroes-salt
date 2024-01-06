#!/bin/bash
STATUS=0

# Run various code validation/syntax checks

source bin/get_colors.sh

TESTS=(
    extension.sh
    empty_files.sh
    secrets.sh
    roles.py
    custom_grains.py
    infra_data.sh
)

for _test in "${TESTS[@]}"; do
    echo_INFO "## Running test_${_test}"
    if "bin/test_${_test}"; then
        echo_PASSED
    else
        echo_FAILED
        STATUS=1
    fi
    echo
done

exit "$STATUS"
