{% set osmajorrelease = salt['grains.get']('osmajorrelease')|int %}

include:
  - SLES.{{ osmajorrelease }}
