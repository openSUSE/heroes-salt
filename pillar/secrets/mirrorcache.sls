#!jinja|yaml|gpg
{% set site = salt['grains.get']('site') %}

mysql:
  user:
    mirrorcache:
      password: |
{%- if site == 'nue-ipx' %}
        -----BEGIN PGP MESSAGE-----

        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
        =/bzH
        -----END PGP MESSAGE-----
{%- elif site == 'prv1' %}
        -----BEGIN PGP MESSAGE-----

        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
        =7+nc
        -----END PGP MESSAGE-----
 {% endif %}
