{%- set directory = '/etc/sysctl.d/' %}
{%- set salt_file = '99-salt.conf' %}
{%- set files = salt['file.find'](directory, print='name', type='f') %}

{#- preserve the file containing our Salt managed values #}
{%- if salt_file in files %}
{%- do files.remove(salt_file) %}
{%- endif %}

{#- delete the rest #}
{%- if files %}
sysctl_purge:
  file.absent:
    - names:
        {%- for file in files %}
        - {{ directory }}{{ file }}
        {%- endfor %}

sysctl_update:
  cmd.run:
    - name: sysctl --system
    - onchanges:
        - file: sysctl_purge
    - require_in:
        - sls: sysctl.param
{%- endif %}

include:
  - sysctl.param
