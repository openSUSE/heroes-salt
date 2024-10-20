{%- set osfullname = grains['osfullname'] %}
{%- set virtual    = grains['virtual'] %}

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
  {%- if virtual == 'kvm' %}
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

  - profile.pam
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

  {%- if virtual == 'physical' %}
  {%- if grains.get('site') in ['prg2', 'slc1'] %}
  - lldpd
  {%- endif %}
  - smartmontools.smartd
  {%- endif %}

  - profile.authorized-exec
  - profile.systemd.daemon-reload
