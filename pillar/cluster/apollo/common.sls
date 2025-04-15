{%- from 'macros.jinja' import bond, slave, smart %}

network:
  interfaces:

    # Physical interfaces
    {{ slave('ob0') }}
    {{ slave('ob1') }}

    # LACP bond
    {{ bond('ob', 'ob0', 'ob1') }}

{{ smart([
      'sda',
      'sdb',
]) }}
