{% set osrelease = salt['grains.get']('osrelease') %}

production:
  '*':
    - common
  'osrelease:{{ osrelease }}':
    - match: grain
    - osrelease.{{ osrelease.replace('.', '_') }}
