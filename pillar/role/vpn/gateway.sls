{%- import_yaml 'infra/nameservers.yaml' as nameservers -%}
{%- import_yaml 'infra/networks.yaml' as networks -%}
{%- set site = grains['site'] -%}

{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.vpn.gateway
{%- endif %}

# OpenVPN configuration is currently in static files under profile/vpn/openvpn/

profile:
  vpn:
    openvpn:
      config:
        push:
          dns:
            {%- for nameserver in nameservers[site] %}
            - {{ nameserver }}
            {%- endfor %}
          routes:
          {%- for network, network_config in networks[site].items() %}
            {%- if network_config.get('vpn_push', false) is sameas true %}
            - {{ network_config['net6'] }}
            {%- endif %}
          {%- endfor %}
          {%- set network64 = networks['pseudo'][site]['openSUSE-NAT64-Pool'] %}
          {%- if network64.get('vpn_push', false) is sameas true %}
            - {{ network64['net6'] }}
          {%- endif %}

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
    python311-python-dateutil: {}

users:
  manage_vpn_users:
    system: true
