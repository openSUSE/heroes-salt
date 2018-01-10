{% set ipv4 = salt['grains.get']('ipv4') %}

chrony:
  allow:
    - 127.0.0.0/8
    - 192.168.47.0/24
    - 192.168.254.0/24
  ntpservers:
    - ntp1.opensuse.org
    - ntp2.opensuse.org
  otherparams:
    - makestep -1 1
    {% for ip in ipv4 %}
    # filter only the priv IPs and exclude the VRRPs
    {% if ip.startswith('192.168') and not ip.endswith('.4') %}
    - bindaddress {{ ip }}
    {% endif %}
    {% endfor %}
    - bindaddress 127.0.0.1
