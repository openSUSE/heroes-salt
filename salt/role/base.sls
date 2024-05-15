{%- set osfullname = grains['osfullname'] %}

{%- if osfullname == 'Leap' %}
/usr/local/libexec:
  file.directory:
    - mode: '0755'
    - order: 1
{%- endif %}

include:
  - profile.legacy
  - network.wicked
  - hostsfile.pillar_only
  - profile.rpmkeys
  - zypper
  {%- if grains['virtual'] == 'kvm' %}
  - profile.qemu-guest-agent
  {%- endif %}

  {%- if osfullname == 'openSUSE Leap Micro' %}
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

  - profile.kanidm.client
  - profile.accounts
  - profile.log
  - profile.monitoring
  - profile.regional
  - infrastructure.salt.minion
  - profile.security
  - profile.services
  - profile.sysctl
  - profile.motd
  - profile.dehydrated.target
  - profile.monitoring.prometheus.textfiles
  - prometheus.config
