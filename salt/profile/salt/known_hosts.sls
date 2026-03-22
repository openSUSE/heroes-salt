include:
  - profile.salt.git

{%- set repo_base_dir = '/srv/ssh_known_hosts' %}
{%- set repo_dir = repo_base_dir ~ '/repository' %}
{%- set base_script = '/usr/local/bin/salt-known_hosts' %}

salt_known_hosts-scripts:
  file.managed:
    - names:
        - {{ base_script }}:
            - source: salt://{{ slspath }}/files/salt-known_hosts.sh.jinja
        - /usr/local/bin/salt-update-known_hosts-git:
            - source: salt://{{ slspath }}/files/salt-update-known_hosts-git.sh.jinja
            - context:
                out_dir: {{ repo_dir }}
                base_script: {{ base_script }}
    - template: jinja
    - user: root
    - group: root
    - mode: '0755'

{%- if salt['file.directory_exists'](repo_base_dir ~ '/.git') %}
salt_known_hosts-repository-clean:
  file.absent:
    - name: {{ repo_base_dir }}
    - require_in:
        - file: salt_known_hosts-repository
{%- endif %}

salt_known_hosts-repository:
  file.directory:
    - name: {{ repo_base_dir }}
    - user: salt
    - group: salt
    - mode: '0755'

  git.cloned:
    - name: https://gitlab.infra.opensuse.org/infra/ssh_known_hosts.git
    - target: {{ repo_dir }}
    - branch: main
    - user: salt
    - require:
        - file: {{ repo_base_dir }}
