include:
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

  - network.wicked
  - profile.etckeeper
  - profile.ldap.client
  - profile.accounts
  - profile.log
  - profile.monitoring
  - profile.regional
  - infrastructure.salt.minion
  - profile.sysctl
  - zypper
