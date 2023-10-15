#!/bin/bash

# Imports the other admins' plus the salt master/syndic's GPG keys into the
# local keyring, and opens the trust menu in order to trust them ultimately

RECIPIENTS=( $(egrep '^\s*0x' encrypted_pillar_recipients) )
SALTMASTER_KEYS_PATH="gpgkeys"

for key in $(ls $SALTMASTER_KEYS_PATH); do
    gpg --import ${SALTMASTER_KEYS_PATH}/${key}
done

for recipient in ${RECIPIENTS[@]}; do
    gpg --recv-key $recipient
done
