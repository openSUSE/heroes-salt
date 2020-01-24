# Secret management and encryption

**For all intents and purposes you should consider this repository to be
publicly accessible, so please make sure to not expose any secret information
(e.g. passwords) via state and configuration files.**

Secret information (e.g. passwords) are managed in an encrypted way to
provide confidentiality within this repository. In particular, we're using
OpenPGP.

The Salt master has its own OpenPGP key and needs to be able to decrypt any
secret for proper deployment. You'll find this key in the following file:
`gpg/B9D45B4366C69C8D75CA3A08F1C33B7A1346F48E.gpg.asc`.

You'll need to import it manually, and won't find it on any public keyserver:

```
$ gpg --import gpg/B9D45B4366C69C8D75CA3A08F1C33B7A1346F48E.gpg.asc
```

You can then create new secrets using the following snippet:

```
$ echo -n "supersecret" | gpg --armor --batch --trust-model always --encrypt -r <KEY-name>
```

`<KEY-name>` should be a OpenPGP key handle and can be listed multiple times.
For the recommended workflow (see below) you should use your own OpenPGP
key handle, so that you will be able to decrypt the secret and can reencrypt it
later on.

The output (OpenPGP armored ASCII text) can be included into any pillar:

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

## Recommended workflow

The recommended workflow for creating a new secret is as follows:

1.) Make sure to have all public keys from `encrypted_pillar_recipients`
2.) Encrypt the secret with your own public key
3.) Run the `reencrypt_pillar.py` script to re-encrypt it for all current
    recipients.

## Reencryption

Whenever changing the list of recipients (i.e. adding new keys and/or
removing keys) you need to reencrypt all pillar data. The recommended way
of doing this is to use the `reencrypt_pillar.py` script in the following way:

```
$ ./bin/reencrypt_pillar.py --recipients-file encrypted_pillar_recipients -r pillar
```

To successfully run this script, you'll need to import all public keys as
referenced in `encrypted_pillar_recipients`.

**NOTE**: Reencryption will only reencrypt the secrets in accordance with the
current list of recipients. It will **not** change and/or update the secrets
itself. Previous recipients might still be able to decrypt old versions of
the encrypted pillar (version control!), so when appropriate, make sure to
also change the secrets themselves.

## More information & references

More information can be found here:

- https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html
- https://www.gnupg.org/gph/en/manual/x110.html
