{%- set keydir = '/etc/pki/rpm-gpg/' %}
{%- set keys = {
      'openSUSE:infrastructure': 'gpg-pubkey-20f13aac'
    }
%}
{%- set repositories = pillar.get('zypper', {}).get('repositories', {}) %}
{%- if 'devel:languages:python' in repositories or 'devel:languages:python:backports' in repositories %}
{%- do keys.update({
      'devel:languages:python': 'gpg-pubkey-edf0d733'
    })
%}
{%- endif %}
{%- if 'darix:apps' in repositories %}
{%- do keys.update({
      'darix:apps': 'gpg-pubkey-2941c2e1'
    })
%}
{%- endif %}

rpmkey_dir:
  file.directory:
    - name: {{ keydir }}

{%- for project, key in keys.items() %}
{%- set keyfile = keydir ~ key %}

rpmkey_file_{{ project }}:
  file.managed:
    - name: {{ keyfile }}
    - source: salt://{{ slspath }}/files/{{ key }}
    - require:
      - file: rpmkey_dir

rpmkey_import_{{ project }}:
  cmd.run:
    - name: rpm --import {{ keyfile }}
    - onchanges:
      - file: rpmkey_file_{{ project }}
    - require:
      - file: rpmkey_dir

{%- endfor %}

{%- if salt['file.directory_exists'](keydir) %}
  {%- set want_files = keys.values() | list %}
  {%- for file in salt['file.find'](keydir, maxdepth=1, mindepth=1, print='name') %}
    {%- if file in want_files %}
# rpmkey_import above only catches file changes, handle someone deleting the key from RPM without removing the file
rpmkey_reimport_{{ file }}:
  cmd.run:
    - name: rpm --import {{ keydir }}{{ file }}
    - unless: rpm --quiet -q {{ file }}
    - require:
      - file: rpmkey_dir
    {%- else %}
rpmkey_delete_{{ file }}:
  file.absent:
    - name: {{ keydir }}{{ file }}

  cmd.run:
    - name: rpm -e {{ file }}
    - onlyif: rpm --quiet -q {{ file }}
    {%- endif %}
  {%- endfor %}
{%- endif %}
