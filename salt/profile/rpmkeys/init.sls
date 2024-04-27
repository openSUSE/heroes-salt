{%- set keydir = '/etc/pki/rpm-gpg/' %}
{%- set keys = {
      'openSUSE:infrastructure': 'gpg-pubkey-20f13aac-6531532b'
    }
%}
{%- set repositories = pillar.get('zypper', {}).get('repositories', {}) %}
{%- if 'devel:languages:python' in repositories or 'devel:languages:python:backports' in repositories %}
{%- do keys.update({
      'devel:languages:python': 'gpg-pubkey-edf0d733-64c6ae0d'
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
    - unless: rpm -q {{ key }}
    - require:
      - file: rpmkey_dir
      - file: rpmkey_file_{{ project }}

{%- endfor %}
