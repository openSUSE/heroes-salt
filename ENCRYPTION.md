# Secret management and encryption

**For all intents and purposes you should consider this repository to be
publicly accessible, so please make sure to not expose any secret information
(e.g. passwords) via state and configuration files.**

Secret information (e.g. passwords) are managed in an encrypted way to
provide confidentiality within this repository. In particular, we're using
OpenPGP.

## Concept

Secrets are encrypted with OpenPGP using public-key cryptography. There are
multiple recipients able to decrypt each secret, one of which is the Salt
master itself using its own key (`B9D45B4366C69C8D75CA3A08F1C33B7A1346F48E`).

## Import of keys

In order to encrypt any secrets, you'll need to have the public keys of all
other recipients available in your own keyring. The list of recipients is
managed in `encrypted_pillar_recipients`.

You can import all keys by invoking the script `bin/import_gpg_keys.sh`.

In case you want to do this manually, you need to keep in mind that the public
key of the Salt master is not uploaded to any public keyserver. You'll find
a copy of this key in `gpgkeys` and can import it using the following command:

```
$ gpg --import gpgkeys/B9D45B4366C69C8D75CA3A08F1C33B7A1346F48E.gpg.asc
```

## Create new secrets

You can easily create new secrets using the `bin/encrypt_pillar.sh` script:

The script will wait for some input (i.e. the secret) and encrypt it, so that
all current recipients can access it. It will then output some OpenPGP armored
ASCII text block, which can then be included into any pillar as block string:


```
#!yaml|gpg

a-secret: |
  -----BEGIN PGP MESSAGE-----
  Version: GnuPG v1

  hQEMAweRHKaPCfNeAQf9GLTN16hCfXAbPwU6BbBK0unOc7i9/etGuVc5CyU9Q6um
  QuetdvQVLFO/HkrC4lgeNQdM6D9E8PKonMlgJPyUvC8ggxhj0/IPFEKmrsnv2k6+
  cnEfmVexS7o/U1VOVjoyUeliMCJlAz/30RXaME49Cpi6No2+vKD8a4q4nZN1UZcG
  RhkhC0S22zNxOXQ38TBkmtJcqxnqT6YWKTUsjVubW3bVC+u2HGqJHu79wmwuN8tz
  m4wBkfCAd8Eyo2jEnWQcM4TcXiF01XPL4z4g1/9AAxh+Q4d8RIRP4fbw7ct4nCJv
  Gr9v2DTF7HNigIMl4ivMIn9fp+EZurJNiQskLgNbktJGAeEKYkqX5iCuB1b693hJ
  FKlwHiJt5yA8X2dDtfk8/Ph1Jx2TwGS+lGjlZaNqp3R1xuAZzXzZMLyZDe5+i3RJ
  skqmFTbOiA===Eqsm
  -----END PGP MESSAGE-----
```

## Reencryption

Whenever changing the list of recipients (i.e. adding new keys and/or
removing keys) you need to reencrypt all pillar data, so that existing secrets
are reencrypted for the new list of recipients. The recommended way of doing
this is to use the `reencrypt_pillar.py` script in the following way:

```
$ ./bin/reencrypt_pillar.py --recipients-file encrypted_pillar_recipients -r pillar
```

**NOTE**: Reencryption will **NOT** change and/or update the secrets itself.
Previous recipients might still be able to decrypt old versions of the
encrypted pillar (version control!), so when necessary, make sure to also
change the secrets themselves.

## More information & references

More information can be found here:

- https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html
- https://www.gnupg.org/gph/en/manual/x110.html
