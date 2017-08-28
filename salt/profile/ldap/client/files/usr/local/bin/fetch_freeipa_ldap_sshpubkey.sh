#!/bin/bash

# Script that fetches the SSH Public Keys for a given user from LDAP/FreeIPA.
# It takes a FreeIPA/LDAP username as first argument, and returns the SSH
# public keys of that user, one per line.
# Used by sshd (see AuthorizedKeysCommand in sshd_config) for ssh
# authentication via SSH public keys stored in LDAP/FreeIPA

ldapsearch -x -LLL -b cn=users,cn=accounts,dc=infra,dc=opensuse,dc=org '(&(objectClass=posixAccount)(uid='"$1"'))' 'ipaSshPubKey' | sed -n '/^ /{H;d};/ipaSshPubKey:/x;$g;s/\n *//g;s/ipaSshPubKey: //gp'
