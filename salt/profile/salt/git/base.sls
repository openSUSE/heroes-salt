{%- set branch = 'production' -%}

salt_repository:
  git.latest:
    - name: https://gitlab.infra.opensuse.org/infra/salt.git
    - target: /srv/salt-git
    - branch: {{ branch }}
    - rev: {{ branch }}
    - user: cloneboy
    - force_checkout: true
    - force_clone: true
    - force_reset: true
    - fetch_tags: false
    - https_user: gitlab_does_not_care_about_this
    - https_pass: {{ salt['pillar.get']('profile:salt:git_secret') }}
