salt:
  gitfs:
    libgit2:
      install_from_source: False
    pygit2:
      install_from_source: False
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
              - privkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt
              - pubkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt.pub
    ext_pillar_first: True
    fileserver_backend:
      - git
    gitfs_provider: pygit2
    gitfs_remotes:
      - gitlab@gitlab.infra.opensuse.org:infra/salt.git:
          - root: salt
          - privkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt
          - pubkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt.pub
      - https://gitlab.opensuse.org/saltstack-formulas/dhcpd-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/grains-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/keepalived-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/limits-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/locale-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/mysql-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/ntp-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/openssh-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/powerdns-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/salt-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/sqlite-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/sudoers-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/timezone-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/users-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/zypper-formula.git
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
