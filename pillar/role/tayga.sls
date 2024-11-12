{%- import_yaml 'infra/hosts.yaml' as hosts %}
{%- import_yaml 'infra/networks.yaml' as networks %}

{%- set nat64_network = networks['pseudo'][grains['site']]['openSUSE-NAT64-Pool'] %}

{%- set nat64_net6 = nat64_network['net6'] %}
{%- set nat64_net4 = nat64_network['net4'] %}
{%- set nat64_range = nat64_net4.split('/')[0].split('.')[:3] | join('.') %}

tayga:
  ipv4-addr: {{ nat64_range ~ '.1' }}
  prefix: {{ nat64_net6 }}
  dynamic-pool: {{ nat64_net4 }}

  {%- set nat64_mappings = {} %}
  {%- for host, host_config in hosts.items() %}
    {%- for interface, interface_config in host_config.get('interfaces', {}).items() %}
      {%- if 'ip6' in interface_config %}
        {%- set address = interface_config.get('pseudo_ip4') %}
        {%- if address is not none and address.startswith(nat64_range) %}
          {%- do nat64_mappings.update({address: salt['os_network.strip_cidr'](interface_config['ip6'])}) %}
        {%- endif %} {#- close address check #}
      {%- endif %} {#- close ip6 check #}
    {%- endfor %} {#- close interfaces loop #}
  {%- endfor %} {#- close hosts loop #}

  {%- if nat64_mappings %}
  maps: {{ nat64_mappings }}
  {%- endif %}
