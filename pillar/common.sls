locale:
  present:
    - 'en_US.UTF-8 UTF-8'
  default:
    name: 'en_US.UTF-8'
    requires: 'en_US.UTF-8 UTF-8'
ntp:
  ng:
    settings:
      ntpd: true
      ntp_conf:
        controlkey:
          - 1
        disable:
          - monitor
        driftfile:
          - /var/lib/ntp/drift/ntp.drift
        logfile:
          - /var/log/ntp
        keys:
          - /etc/ntp.keys
        requestkey:
          - 1
        restrict:
          - -4 default kod notrap nomodify nopeer
          - -6 default kod notrap nomodify nopeer
          - 127.0.0.1
          - ::1
        trustedkey:
          - 1
timezone:
  name: 'UTC'
  utc: True
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
          - production gitlab@gitlab.opensuse.org:infra/salt.git:
              - env: production
              - root: pillar
              - privkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt
              - pubkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt.pub
    ext_pillar_first: True
    fileserver_backend:
      - git
    gitfs_provider: pygit2
    gitfs_remotes:
      - gitlab@gitlab.opensuse.org:infra/salt.git:
          - root: salt
          - privkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt
          - pubkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt.pub
      - https://gitlab.opensuse.org/saltstack-formulas/dhcpd-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/grains-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/keepalived-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/locale-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/ntp-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/openssh-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/salt-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/sudoers-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/users-formula.git
      - https://gitlab.opensuse.org/saltstack-formulas/timezone-formula.git
    gitfs_ssl_verify: True
    hash_type: sha512
    pillar_gitfs_ssl_verify: True
    pillar_merge_lists: True
    pillar_source_merging_strategy: smart
    state_output: changes
    state_verbose: False
    top_file_merging_strategy: same
    user: salt
  minion:
    backup_mode: minion
    environment: production
    hash_type: sha512
