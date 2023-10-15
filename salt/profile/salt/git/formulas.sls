{%- set formulas_git = salt['pillar.get']('profile:salt:formulas:git') -%}
{%- set branch = 'production' -%}
{%- set srcdir = '/srv/formula-src' -%}
{%- set dstdir = '/srv/formula' -%}

salt_formula_clone:
  git.latest:
    - name: https://gitlab.infra.opensuse.org/infra/salt-formulas-git.git
    - target: {{ srcdir }}
    - branch: {{ branch }}
    - rev: {{ branch }}
    - user: cloneboy
    - force_checkout: true
    - force_clone: true
    - force_reset: true
    - fetch_tags: false
    - submodules: true

salt_formula_base_directories:
  file.directory:
    - names:
      - {{ dstdir }}
      - {{ dstdir }}/_modules
      - {{ dstdir }}/_states

salt_formula_links:
  file.symlink:
    - names:
        {%- for formula, config in formulas_git.items() %}
        {%- set fbase = '/srv/formula-src/' ~ formula ~ '-formula' %}
        - {{ dstdir }}/{{ formula }}:
          - target: {{ fbase }}/{{ formula }}
        {%- set modules = config.get('modules', {}) %}
        {%- for module in modules.get('execution', []) %}
        - {{ dstdir }}/_modules/{{ module }}:
          - target: {{ fbase }}/_modules/{{ module }}
        {%- endfor %}
        {%- for module in modules.get('state', []) %}
        - {{ dstdir }}/_states/{{ module }}:
          - target: {{ fbase }}/_states/{{ module }}
        {%- endfor %}
        {%- endfor %}
