{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.saltmaster
{% endif %}

salt:
  # salt on 15.1 uses py3, therefore different package name
  pygit2: python3-pygit2
  master:
    cli_summary: True
    default_top: production
    env_order:
      - production
    ext_pillar:
      - git:
          - production gitlab@gitlab.infra.opensuse.org:infra/salt.git:
              - env: production
              - root: pillar
              - privkey: /var/lib/salt/.ssh/salt_gitlab_ioo_infra_salt
              - pubkey: /var/lib/salt/.ssh/salt_gitlab_ioo_infra_salt.pub
    ext_pillar_first: True
    fileserver_backend:
      - git
    gitfs_provider: pygit2
    gitfs_remotes:
      - gitlab@gitlab.infra.opensuse.org:infra/salt.git:
          - root: salt
          - privkey: /var/lib/salt/.ssh/salt_gitlab_ioo_infra_salt
          - pubkey: /var/lib/salt/.ssh/salt_gitlab_ioo_infra_salt.pub
      {% import_yaml "FORMULAS.yaml" as formulas_yaml %}
      {% set formulas = formulas_yaml.keys()|sort %}
      {% for formula in formulas %}
      - https://gitlab.infra.opensuse.org/saltstack-formulas/{{ formula }}-formula.git
      {% endfor %}
    gitfs_ssl_verify: True
    hash_type: sha512
    pillar_gitfs_ssl_verify: True
    pillar_merge_lists: True
    pillar_source_merging_strategy: smart
    state_output: changes
    state_verbose: False
    top_file_merging_strategy: same
    user: salt
  reactor:
    - 'salt/fileserver/gitfs/update':
        - /srv/reactor/update_fileserver.sls
