{%- set osfullname = salt['grains.get']('osfullname') %}
{% set osmajorrelease = salt['grains.get']('osmajorrelease')|int %}
{% set osrelease = salt['grains.get']('osrelease') %}
{%- set virtual = salt['grains.get']('virtual') -%}
{%- set country = salt['grains.get']('country') -%}
{%- set address = salt['saltutil.runner']('os_pillar.get_host_ip6', arg=[grains['host'], True]) -%}
{%- set configure_ntp = salt['grains.get']('configure_ntp', True) %}

include:
  - .bootloader
  - .certificates
  - .firewall
  - .headers
  - .hosts
  - .limits
  - .motd
  - .network
  - .sudo
  - .sysctl
  - .update

apparmor:
  profiles:
    usr.sbin.chronyd:
      source: salt://profile/apparmor/files/chronyd.apparmor.jinja
      template: jinja

chrony:
  driftfile: /var/lib/chrony/drift
  logdir: /var/log/chrony
  {%- if configure_ntp %}
  ntpservers:
    - ntp1.infra.opensuse.org
    - ntp2.infra.opensuse.org
  {%- endif %}
  otherparams:
    {%- if configure_ntp %}
    - logchange 0.5
    - makestep 1.0 3
    - noclientlog
    {%- endif %}
    - rtcsync
    - 'cmdport 0'

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
  sshd_config_mode: '0640'
  banner_string: Welcome to {{ grains['id'] }}!
profile:
  log:
    {%- if country == 'cz' %}
    rsyslog_host: 2a07:de40:b27e:1203::50
    {%- else %}
    rsyslog_host: 172.16.164.40
    {%- endif %}
  postfix:
    aliases:
      root: admin-auto@opensuse.org
    maincf:
      relayhost: '[relay.infra.opensuse.org]'
      myhostname: '{{ grains['host'] }}.infra.opensuse.org'
      smtpd_data_restrictions: reject_unauth_pipelining
      {%- if country == 'cz' %}
      inet_protocols: ipv6
      {%- endif %}
rsyslog:
  custom:
    - salt://profile/log/files/etc/rsyslog.d/remote.conf.jinja
  custom_config_template: salt://profile/log/files/etc/rsyslog.conf
  exclusive: false
  imjournal: true
  protocol: tcp
  target: syslog.infra.opensuse.org
salt:
  {%- if country == 'cz' %}
  {#- to-do: deploy IPv6 globally #}
  ipv6: true
  {%- endif %}
  minion_remove_config: true
  minion:
    backup_mode: minion
    enable_gpu_grains: false
    grains_cache: true
    grains_cache_expiration: 86400
    saltenv: production
    startup_states: sls
    sls_list:
      - grains
    hash_type: sha512
    master:
      - witch1.infra.opensuse.org
      #- witch2.infra.opensuse.org (not ready yet)
    {%- if osfullname == 'openSUSE Leap Micro' %}
    module_executors:
      - transactional_update
      - direct_call
    {%- endif %}
    snapper_states: true
    features:
        x509_v2: true
    {%- if country == 'us' %}
    {#- high latency tuning #}
    auth_timeout: 15
    ping_interval: 30
    random_reauth_delay: 30
    random_startup_delay: 5
    request_channel_timeout: 60
    return_retry_timer: 30
    return_retry_timer_max: 60
    {%- endif %}
ssh_config:
  Ciphers:
    - -chacha20‐poly1305@openssh.com
sshd_config:
  AuthorizedKeysFile: .ssh/authorized_keys
  AuthorizedKeysCommand: /usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
  AuthorizedKeysCommandUser: nobody
  Ciphers:
    - -chacha20‐poly1305@openssh.com
  HostKey:
    - /etc/ssh/ssh_host_rsa_key
    - /etc/ssh/ssh_host_dsa_key
    - /etc/ssh/ssh_host_ecdsa_key
    - /etc/ssh/ssh_host_ed25519_key
  {%- if address is not none %}
  ListenAddress: {{ address }}
  {%- endif %}
  PasswordAuthentication: no
  PermitRootLogin: without-password
  PrintMotd: yes
  # TODO: upstream fix is not sufficient https://github.com/saltstack-formulas/openssh-formula/pull/57
  Subsystem: sftp /usr/lib/ssh/sftp-server
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
          {%- if grains.get('country') == 'cz' %}
          lookup_family_order: ipv6_only
          {%- endif %}
      general_settings:
        config_file_version: 2
        domains: infra.opensuse.org
        services: nss, pam, ssh
      services:
        nss:
          filter_groups: root
          filter_users: root
        pam: {}
        ssh: {}
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
    {%- if osfullname == 'openSUSE Leap Micro' %}
    toolmux: {}
    patterns-microos-sssd_ldap: {}
    {%- else %}
    {#- either not available, part of the basesystem, or not needed on Micro #}
    aaa_base-extras: {}
    ca-certificates-mozilla: {}
    curl: {}
    git-core: {}
    htop: {}
    less: {}
    lsof: {}
    {%- if virtual == 'kvm' %}
    qemu-guest-agent: {}
    {%- endif %}
    {%- if grains['efi'] %}
    shim: {}
    {%- endif %}
    sssd-ldap: {}
    tcpdump: {}
    tmux: {}
    traceroute: {}
    vim: {}
    vim-data: {}
    withlock: {}
    {%- endif %} {#- Close Leap Micro check #}
  refreshdb_force: false

mine_functions:
  network.ip_addrs: []
  network.ip_addrs6: []
  fqdn:
    - mine_function: grains.get
    - fqdn
  ssh_host_keys:
    - mine_function: ssh.host_keys
    - private: False
    - certs: False
