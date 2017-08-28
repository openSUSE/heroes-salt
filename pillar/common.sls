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
          - default ignore
          - -4 default kod notrap nomodify nopeer
          - -6 default kod notrap nomodify nopeer
          - 127.0.0.1
          - ::1
        trustedkey:
          - 1
openssh:
  banner_src: salt://profile/accounts/files/ssh_banner
  sshd_config_mode: 0640
salt:
  minion:
    backup_mode: minion
    environment: production
    hash_type: sha512
sshd_config:
  AuthorizedKeysCommand: /usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
  AuthorizedKeysCommandUser: nobody
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
sssd:
  settings:
    sssd: True
    sssd_conf:
      domains:
        infra.opensuse.org:
          auth_provider: ldap
          id_provider: ldap
          ldap_group_search_base = cn=groups,cn=compat,dc=infra,dc=opensuse,dc=org
          ldap_search_base: dc=infra,dc=opensuse,dc=org
          ldap_tls_reqcert: demand
          ldap_uri: ldaps://freeipa.infra.opensuse.org
          ldap_user_search_base = cn=users,cn=accounts,dc=infra,dc=opensuse,dc=org
      general_settings:
        config_file_version: 2
        domains: infra.opensuse.org
        services: nss, pam, ssh
      services:
        nss:
          filter_group: root
          filter_users: root
        pam: {}
        ssh: {}
sudoers:
  defaults:
    generic:
      - always_set_home
      - secure_path="/usr/sbin:/usr/bin:/sbin:/bin"
      - env_reset
      - env_keep="LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE"
      - '!insults'
  users:
    root:
      - 'ALL=(ALL) ALL'
  includedir: /etc/sudoers.d
  included_files:
    /etc/sudoers.d/nagios_nopasswd_zypper:
      users:
        nagios:
          - 'ALL=(ALL) NOPASSWD: /usr/sbin/zypp-refresh,/usr/bin/zypper ref,/usr/bin/zypper sl,/usr/bin/zypper --xmlout --non-interactive list-updates -t package -t patch'
    /etc/sudoers.d/wheel:
      groups:
        wheel:
          - 'ALL=(ALL) ALL'
zypper:
  config:
    zypp_conf:
      main:
        download.use_deltarpm: 'false'
        solver.onlyRequires: 'true'
  packages:
    abuild-online-update: {}
    ca-certificates-freeipa-opensuse: {}
    curl: {}
    dhcp-client: {}
    less: {}
    lsof: {}
    man: {}
    mtr: {}
    openldap2-client: {}
    openssh-helpers: {}
    screen: {}
    sssd-ldap: {}
    susepaste: {}
    tcpdump: {}
    traceroute: {}
    vim: {}
    vim-data: {}
    wget: {}
    wgetpaste: {}
