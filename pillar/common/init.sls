{%- set osfullname = salt['grains.get']('osfullname') %}
{% set osmajorrelease = salt['grains.get']('osmajorrelease')|int %}
{% set osrelease = salt['grains.get']('osrelease') %}
{%- set virtual = salt['grains.get']('virtual') -%}

include:
  - .headers
  - .limits
  - .sysctl

chrony:
  driftfile: /var/lib/chrony/drift
  logdir: /var/log/chrony
  otherparams:
    {% if salt['grains.get']('configure_ntp', True) %}
    - logchange 0.5
    - log measurements statistics tracking rtc
    - makestep 1.0 3
    - noclientlog
    {% endif %}
    - rtcsync
locale:
  present:
    - en_US.UTF-8 UTF-8
  default:
    name: en_US.UTF-8
    requires: en_US.UTF-8 UTF-8
openldap:
  base: dc=infra,dc=opensuse,dc=org
  tls_cacertdir: /etc/ssl/certs/
  tls_reqcert: demand
  uri: ldaps://freeipa.infra.opensuse.org
openssh:
  banner_src: salt://profile/accounts/files/ssh_banner
  sshd_config_mode: 0640
profile:
  postfix:
    aliases:
      root: admin-auto@opensuse.org
    maincf:
      relayhost: '[relay.infra.opensuse.org]'
      myhostname: '{{ grains['host'] }}.infra.opensuse.org'
rsyslog:
  custom:
    - salt://profile/log/files/etc/rsyslog.d/remote.conf.jinja
  custom_config_template: salt://profile/log/files/etc/rsyslog.conf
  imjournal: true
  protocol: tcp
  target: syslog.infra.opensuse.org
salt:
  minion_remove_config: true
  minion:
    backup_mode: minion
    saltenv: production
    hash_type: sha512
    ipv6: false
    {%- if osfullname == 'openSUSE Leap Micro' %}
    module_executors:
      - transactional_update
      - direct_call
    {%- endif %}
sshd_config:
  AuthorizedKeysFile: .ssh/authorized_keys
  AuthorizedKeysCommand: /usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
  AuthorizedKeysCommandUser: nobody
  HostKey:
    - /etc/ssh/ssh_host_rsa_key
    - /etc/ssh/ssh_host_dsa_key
    - /etc/ssh/ssh_host_ecdsa_key
    {% if osrelease != '11.3' %}
    - /etc/ssh/ssh_host_ed25519_key
    {% endif %}
  PasswordAuthentication: no
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
  UsePAM: yes
  matches:
    root:
      type:
        User: root
      options:
        Banner: /etc/ssh/banner
sssd:
  settings:
    sssd: True
    sssd_conf:
      domains:
        infra.opensuse.org:
          auth_provider: ldap
          id_provider: ldap
          ldap_group_search_base: cn=groups,cn=compat,dc=infra,dc=opensuse,dc=org
          ldap_search_base: dc=infra,dc=opensuse,dc=org
          ldap_tls_reqcert: demand
          ldap_uri: ldaps://freeipa.infra.opensuse.org
          ldap_user_search_base: cn=users,cn=accounts,dc=infra,dc=opensuse,dc=org
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
    {%- if virtual == 'physical' %}
    /etc/sudoers.d/nagios_nopasswd_hypervisors:
      users:
        nagios:
          - 'ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/check_md_raid, /sbin/multipath, /usr/bin/ipmitool'
    {%- endif %}
timezone:
  name: UTC
  utc: True
zypper:
  config:
    zypp_conf:
      main:
        download.use_deltarpm: 'false'
        solver.onlyRequires: 'true'
  packages:
    ca-certificates-freeipa-opensuse: {}
    {%- if osfullname != 'openSUSE Leap Micro' %}
    {#- either not available, part of the basesystem, or not needed #}
    curl: {}
    dhcp-client: {}
    less: {}
    lsof: {}
    man: {}
    openssh-helpers: {}
    screen: {}
    tcpdump: {}
    susepaste: {}
    vim: {}
    vim-data: {}
    wget: {}
    wgetpaste: {}
    suse-online-update: {}
    withlock: {}
    {%- if osrelease | float > 15.4 %}
    scout-command-not-found: {}
    {%- else %}
    command-not-found: {}
    {%- endif %}
    {%- if osmajorrelease > 11 %}
    aaa_base-extras: {}
    ca-certificates-mozilla: {}
    htop: {}
    mtr: {}
    tmux: {}
    traceroute: {}
    {%- endif %}
    {%- endif %}
    sssd-ldap: {}
  refreshdb_force: false

mine_functions:
  network.ip_addrs: []
