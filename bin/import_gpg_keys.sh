#!/bin/bash

set -eu
shopt -s nullglob

# Imports the other admins' plus the salt master/syndic's GPG keys into the
# local keyring

RECIPIENTS=( $(grep -E '^\s*0x' encrypted_pillar_recipients) )

for key in gpgkeys/*.asc; do
    gpg --import "$key"
done

for recipient in "${RECIPIENTS[@]}"; do
    gpg --list-key "$recipient" || gpg --recv-key "$recipient"
done
