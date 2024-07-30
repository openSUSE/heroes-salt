{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.vpn.gateway
{%- endif %}

# OpenVPN configuration is currently in static files under profile/vpn/openvpn/

sysctl:
  params:
    net.ipv6.conf.all.forwarding: 1

zypper:
  packages:
    # needed by salt/profile/vpn/openvpn/ccd.sls
    python3-python-dateutil: {}
    # needed by salt/profile/vpn/openvpn/files/manage_inactive_accounts.py.jinja
    python311: {}
    python311-urllib3: {}
