salt_git_user:
  user.present:
    - name: cloneboy
    - usergroup: false
    - fullname: Git Cloney
    - system: true
    - home: /var/lib/cloneboy
    - createhome: false
    - shell: /sbin/nologin
    - require_in:
      - file: salt_git_directory
      - file: salt_formulas_directory

salt_git_directory:
  file.directory:
    - name: /srv/salt-git
    - user: cloneboy
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
  - .base
  - .formulas
