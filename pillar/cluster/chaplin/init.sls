{%- from 'macros.jinja' import smart %}

include:
  - .network

{{ smart([
      'sda',
      'sdb',
]) }}
