include:
  - profile.legacy
  - network.wicked
  - hostsfile.pillar_only
  - profile.rpmkeys
  - zypper
  {%- if grains['virtual'] == 'kvm' %}
  - profile.qemu-guest-agent
  {%- endif %}

  {%- if grains['osfullname'] == 'openSUSE Leap Micro' %}
  - profile.tukit
  - profile.salt.micro
  {%- else %}
  - profile.apparmor
  - profile.postfix
  {%- endif %}

  - bootloader
  - firewalld
  - profile.nftables
  - os_update
  - rebootmgr
  - profile.etckeeper

  {%- if 'kanidm-client' not in pillar.get('roles', {}) %}
  - profile.pam
  - profile.ldap.client
  {%- endif %}

  - profile.accounts
  - profile.log
  - profile.monitoring
  - profile.regional
  - infrastructure.salt.minion
  - profile.services
  - profile.sysctl
  - profile.motd
  - profile.dehydrated.target
  - prometheus.config
