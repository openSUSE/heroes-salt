#!/bin/bash

set -eu
shopt -s nullglob

# Imports the other admins' plus the salt master/syndic's GPG keys into the
# local keyring, and opens the trust menu in order to trust them ultimately

RECIPIENTS=( $(grep -E '^\s*0x' encrypted_pillar_recipients) )

for key in gpgkeys/*.asc; do
    gpg --import "$key"
done

for recipient in "${RECIPIENTS[@]}"; do
    gpg --recv-key "$recipient"
done
