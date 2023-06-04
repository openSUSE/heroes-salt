{%- set formulas_git = salt['pillar.get']('profile:salt:formulas:git') -%}

salt_formulas_directory:
  file.directory:
    - name: /srv/formulas
    - user: cloneboy
    - group: salt

{%- for formula in formulas_git %}
salt_formula_{{ formula }}:
  git.latest:
    - name: https://gitlab.infra.opensuse.org/saltstack-formulas/{{ formula }}-formula.git
    - target: /srv/formulas/{{ formula }}-formula
    - branch: production
    - user: cloneboy
    - require:
      - file: salt_formulas_directory
{%- endfor %}
