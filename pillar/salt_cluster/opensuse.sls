{% set subrole_ntp = salt['grains.get']('subrole_ntp', '') %}
{%- set country = grains.get('country', 'cz') %}

chrony:
  ntpservers:
   {% for n in range(3) %}
   {% if subrole_ntp != 'ntp{0}'.format(n+1) %}
   - ntp{{ n+1 }}.infra.opensuse.org
   {% endif %}
   {% endfor %}
profile:
  log:
    rsyslog_host: 192.168.47.7
salt:
  minion:
    {%- if country == 'cz' %}
    master:
      - witch1.infra.opensuse.org
      #- witch2.infra.opensuse.org (not ready yet)
    {%- else %}
    master: minnie.infra.opensuse.org
    {%- endif %}
