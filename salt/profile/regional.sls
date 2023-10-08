include:
  - chrony
{%- if grains['osfullname'] != 'openSUSE Leap Micro' %}
{#- on SLE Micro glibc-locale does not exist, and the timezone_setting ID throws a false exception about the system not being booted with systemd  - but since /etc/localtime links to UTC by default anyways, we just skip the formula there #}
  - locale
  - timezone
{%- endif %}
