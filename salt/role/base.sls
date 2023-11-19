include:
  - profile.legacy
  - network.wicked
  - profile.rpmkeys
  - zypper
  {%- if grains['virtual'] == 'kvm' %}
  - profile.qemu-guest-agent
  {%- endif %}
  {%- if grains.get('country') == 'cz' %}
  - profile.prg2_bootstrap
  {%- endif %}

  {%- if grains['osfullname'] == 'openSUSE Leap Micro' %}
  - profile.tukit
  - profile.salt.micro
  {%- else %}
  - profile.apparmor
  - profile.postfix
  {%- endif %}

  - bootloader
  - os_update
  - rebootmgr
  - profile.etckeeper
  - profile.ldap.client
  - profile.accounts
  - profile.log
  - profile.monitoring
  - profile.regional
  - infrastructure.salt.minion
  - profile.sysctl
