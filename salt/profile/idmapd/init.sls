{%- set file = '/etc/idmapd.conf' %}

{{ file }}:
  file.managed:
    - source: salt://{{ slspath }}/files{{ file }}
    - template: jinja

nfsidmap_clear_keyring:
  cmd.run:
    - name: nfsidmap -c
    - onchanges:
        - file: {{ file }}
