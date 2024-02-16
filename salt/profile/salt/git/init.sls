salt_git_user:
  user.present:
    - name: cloneboy
    - usergroup: false
    - fullname: Git Cloney
    - system: true
    - home: /var/lib/cloneboy
    - createhome: false
    - shell: /sbin/nologin

salt_git_directory:
  file.directory:
    - names:
        - /srv/salt-git
        - /srv/formulas
    - user: cloneboy
    - group: salt
    - require:
        - user: salt_git_user
    - require_in:
        - git: salt_formula_clone

{%- for l in ['salt', 'pillar'] %}
salt_git_link_{{ l }}:
  file.symlink:
    - name: /srv/{{ l }}
    - target: /srv/salt-git/{{ l }}
    - force: true
    - require:
        - file: salt_git_directory
{%- endfor %}

include:
  - .formulas
