#!/bin/bash

# Helper script that with variables needed for colorizing the test output

echo_PASSED() {
    echo -e "\e[32mPASSED\e[0m"
}

echo_FAILED() {
    echo -e "\e[31mFAILED\e[0m"
}

echo_INFO() {
    echo -e "\e[33m${1}\e[0m"
}
