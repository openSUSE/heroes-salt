{% set roles = salt['grains.get']('roles', []) %}

ipsilon_dependencies:
  pkg.installed:
    - pkgs:
      - ipsilon
      - ipsilon-openid
      - ipsilon-saml2
      - ipsilon-persona
      - ipsilon-authgssapi
      - ipsilon-openidc

