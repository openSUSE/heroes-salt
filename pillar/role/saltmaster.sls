{%- import_yaml 'FORMULAS.yaml' as formulas_yaml -%}
{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.saltmaster
{% endif %}

salt:
  master_remove_config: True
  master:
    cli_summary: True
    default_top: production
    ext_pillar_first: True
    fileserver_backend:
      - git
      - roots
    file_roots:
      __env__:
        - /srv/salt
        - /usr/share/salt-formulas/states
        - /srv/formula
    gitfs_ssl_verify: True
    hash_type: sha512
    interface: '::'
    pillar_gitfs_ssl_verify: True
    pillar_merge_lists: True
    pillar_roots:
      __env__:
        - /srv/pillar
    pillar_source_merging_strategy: smart
    state_output: changes
    state_verbose: False
    top_file_merging_strategy: same
    user: salt
  reactor:
    - 'salt/fileserver/gitfs/update':
        - /srv/reactor/update_fileserver.sls

infrastructure:
  salt:
    formulas:
      {%- for formula in formulas_yaml['package'] %}
      - {{ formula }}-formula
      {%- endfor %}
    reactor:
      update_fileserver_ng:
        target: minnie.infra.opensuse.org

sudoers:
  included_files:
    /etc/sudoers.d/gitlab-runner_nopasswd_salt_event:
      users:
        gitlab-runner:
          - 'ALL=(root) NOPASSWD:SETENV: /usr/bin/salt-call event.*'

profile:
  salt:
    formulas:
      git:
        {%- for formula, config in formulas_yaml['git'].items() %}
        {{ formula }}: {{ config }}
        {%- endfor %}
