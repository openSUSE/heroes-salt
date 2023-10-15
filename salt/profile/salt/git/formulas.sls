{%- set branch = 'production' -%}

salt_formulas:
  git.latest:
    - name: https://gitlab.infra.opensuse.org/infra/salt-formulas-git.git
    - target: /srv/formulas
    - branch: {{ branch }}
    - rev: {{ branch }}
    - user: cloneboy
    - force_checkout: true
    - force_clone: true
    - force_reset: true
    - fetch_tags: false
    - submodules: true
