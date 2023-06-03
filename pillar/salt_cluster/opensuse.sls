{% set subrole_ntp = salt['grains.get']('subrole_ntp', '') %}

chrony:
  ntpservers:
   {% for n in range(3) %}
   {% if subrole_ntp != 'ntp{0}'.format(n+1) %}
   - ntp{{ n+1 }}.infra.opensuse.org
   {% endif %}
   {% endfor %}
{% if salt['grains.get']('configure_ntp', True) %}
ntp:
  ng:
    settings:
      ntp_conf:
        server:
          - ntp1.infra.opensuse.org iburst
          - ntp2.infra.opensuse.org iburst
          - ntp3.infra.opensuse.org iburst
{% endif %}
profile:
  log:
    rsyslog_host: 192.168.47.7
salt:
  minion:
    master: minnie.infra.opensuse.org
