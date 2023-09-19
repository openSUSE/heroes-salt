include:

  {%- if grains['osfullname'] == 'openSUSE Leap Micro' %}
  - profile.tukit
  {%- else %}
  - profile.apparmor
  - profile.postfix
  {%- endif %}

  - profile.etckeeper
  - profile.ldap.client
  - profile.accounts
  - profile.log
  - profile.monitoring
  - profile.regional
  - infrastructure.salt.minion
  - profile.sysctl
  - zypper
