{% set osrelease = salt['grains.get']('osrelease') %}

locale:
  present:
    - en_US.UTF-8 UTF-8
  default:
    name: en_US.UTF-8
    requires: en_US.UTF-8 UTF-8
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
          - production gitlab@mickey.opensuse.org:infra/salt.git:
              - env: production
              - root: pillar
              - privkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt
              - pubkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt.pub
    ext_pillar_first: True
    fileserver_backend:
      - git
    gitfs_provider: pygit2
    gitfs_remotes:
      - gitlab@mickey.opensuse.org:infra/salt.git:
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
sshd_config:
  HostKey:
    - /etc/ssh/ssh_host_rsa_key
    - /etc/ssh/ssh_host_dsa_key
    - /etc/ssh/ssh_host_ecdsa_key
    {% if osrelease != '11.3' %}
    - /etc/ssh/ssh_host_ed25519_key
    {% endif %}
  PermitRootLogin: without-password
  PrintMotd: yes
  {% if osrelease.startswith('11') and (salt['grains.get']('cpuarch') == 'x86_64') %}
  # TODO: support more 64bit archs https://progress.opensuse.org/issues/15794
  Subsystem: sftp /usr/lib64/ssh/sftp-server
  {% else %}
  # TODO: upstream fix is not sufficient https://github.com/saltstack-formulas/openssh-formula/pull/57
  Subsystem: sftp /usr/lib/ssh/sftp-server
  {% endif %}
  UseDNS: yes
  matches:
    root:
      type:
        User: root
      options:
        Banner: /etc/ssh/banner
timezone:
  name: UTC
  utc: True
sudoers:
  defaults:
    generic:
      - always_set_home
      - secure_path="/usr/sbin:/usr/bin:/sbin:/bin"
      - env_reset
      - env_keep="LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE"
      - '!insults'
      - targetpw
  users:
    ALL:
      - 'ALL=(ALL) ALL'
    root:
      - 'ALL=(ALL) ALL'
  includedir: /etc/sudoers.d
  included_files:
    /etc/sudoers.d/nagios_nopasswd_zypper:
      users:
        nagios:
          - 'ALL=(ALL) NOPASSWD: /usr/sbin/zypp-refresh,/usr/bin/zypper ref,/usr/bin/zypper sl,/usr/bin/zypper --xmlout --non-interactive list-updates -t package -t patch'
zypper:
  config:
    zypp_conf:
      main:
        solver.onlyRequires: 'true'
  packages:
    aaa_base-extras: {}
