salt_git_directory:
  file.directory:
    - name: /srv/salt-git
    - user: salt
    - group: salt
    - require_in:
      - git: salt_repository

{%- for l in ['salt', 'pillar'] %}
salt_git_link_{{ l }}:
  file.symlink:
    - name: /srv/{{ l }}
    - target: /srv/salt-git/{{ l }}
    - force: true
{%- endfor %}

include:
  - .update
