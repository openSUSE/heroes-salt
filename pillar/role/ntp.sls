{% set subrole_ntp = salt['grains.get']('subrole_ntp') %}

ntp:
  ng:
    settings:
      ntp_conf:
        peer:
          {% for n in range(3) %}
          {% if subrole_ntp != 'ntp{0}'.format(n+1) %}
          - ntp{{ n+1 }}.infra.opensuse.org
          {% endif %}
          {% endfor %}
        restrict:
          - ntp1.opensuse.org
          - ntp2.opensuse.org
          - 192.168.47.0 mask 255.255.255.0 kod nomodify notrap nopeer noquery
          - 192.168.254.0 mask 255.255.255.0 kod nomodify notrap nopeer noquery
        server:
          - ntp1.opensuse.org iburst prefer
          - ntp2.opensuse.org iburst
