{%- set host = grains['host'] %}

network:
  interfaces:
    eth0:
      bootproto: none
      startmode: auto

    os-p2p-pub:
      vlan_id: 3201
      etherdevice: eth0

    {%- import_yaml 'infra/networks.yaml' as country_networks %}
    {%- set networks = country_networks['cz'] %}

    {%- for vlan, config in networks.items() %}
    {{ config['short'][:14] }}:
      etherdevice: eth0
      vlan_id: {{ config['id'] }}
      addresses:
        {%- if 'gw6' in config and config['gw6'].endswith('::') %}
        - {{ salt['os_network.gw_with_cidr'](config['gw6'] ~ host[-1], config['net6']) }}
        {%- endif %}
        {%- if 'gw4' in config %}
        - {{ salt['os_network.gw_with_cidr'](config['gw4'][:-1] ~ host[-1], config['net4']) }}
        {%- endif %}

    {{ 'd-' ~ config['short'][:12] }}:
      bootproto: none
      interfacetype: dummy
    {%- endfor %}

  routes:
    default6:
      gateway: 2a07:de40:b27f:201:ffff:ffff:ffff:ffff
    default4:
      gateway: 195.135.223.46
