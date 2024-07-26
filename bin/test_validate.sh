#!/bin/bash
STATUS=0

# Run various code validation/syntax checks

source bin/get_colors.sh

TESTS=(
    test_extension.sh
    test_empty_files.sh
    test_secrets.sh
    test_profiles.py
    test_roles.py
    test_custom_grains.py
    test_infra_data.sh
)

for _test in "${TESTS[@]}"; do
    echo_INFO "## Running ${_test}"
    if "bin/${_test}"; then
        echo_PASSED
    else
        echo_FAILED
        STATUS=1
    fi
    echo
done

exit "$STATUS"
