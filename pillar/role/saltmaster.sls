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
      # consider changing back to __env__ after a solution for https://github.com/saltstack/salt/issues/62967
      production:
        - /srv/salt
        - /usr/share/salt-formulas/states
        - /srv/formula
    gitfs_ssl_verify: True
    hash_type: sha512
    {%- if grains.get('country') == 'cz' %}
    {#- _needs_ to align with the "ipv6" setting in pillar.common! #}
    interface: '::'
    {%- endif %}
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

profile:
  salt:
    formulas:
      git:
        {%- for formula, config in formulas_yaml['git'].items() %}
        {{ formula }}: {{ config }}
        {%- endfor %}

rsync:
  modules:
    salt-push:
      path: /srv/salt-git/
      comment: /srv/salt-git/
      list: 'false'
      uid: root
      gid: salt
      'auth users': saltpush
      'read only': 'false'
      'secrets file': /etc/rsyncd.secrets
      'hosts allow':
        {%- if grains.get('country') == 'cz' %}
        - 2a07:de40:b27e:1203::126 # gitlab-runner1
        - 2a07:de40:b27e:1203::127 # gitlab-runner2
        {%- else %}
        - 172.16.164.126
        - 172.16.164.127
        {%- endif %}
