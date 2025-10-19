{%- set mypillar = salt['pillar.get']('profile:tc', {}) %}

include:
  - network.wicked.interfaces

{%- if mypillar %}
profile_tc_script:
  file.managed:
    - name: /usr/local/libexec/dotc
    - source: salt://{{ slspath }}/files/tc.sh.jinja
    - mode: '0750'
    - template: jinja
    - require_in:
        - file: network_wicked_ifcfg_settings

{%- set interfaces = mypillar.get('interfaces', []) %}

{%- if interfaces %}
profile_tc_reset:
  cmd.run:
    - names:
        {%- for interface in interfaces %}
        - /usr/local/libexec/dotc reset {{ interface }}
        {%- endfor %}
    - onchanges:
        - file: profile_tc_script
{%- endif %}

{%- else %}
profile_tc_script:
  file.absent:
    - name: /usr/local/libexec/dotc
{%- endif %}
