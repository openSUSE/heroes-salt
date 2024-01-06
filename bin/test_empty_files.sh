#!/bin/bash

EMPTY=$(find . -type f -empty)

if [[ -n $EMPTY ]]; then
    echo "The following files are empty:"
    for file in "${EMPTY[@]}"; do
        echo "${file}"
    done
    exit 1
fi
