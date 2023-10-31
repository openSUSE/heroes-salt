{%- import_yaml 'infra/hosts.yaml' as hosts %}
{%- set nat64_range = '172.16.164' %}
{%- set nat64_network = nat64_range ~ '.0/24' %}

tayga:
  ipv4-addr: {{ nat64_range ~ '.1' }}
  prefix: 2a07:de40:b27e:64::/96
  dynamic-pool: {{ nat64_network }}
  maps:
    {%- for host, host_config in hosts.items() %}
    {%- for interface, interface_config in host_config.get('interfaces', {}).items() %}
    {%- if 'ip6' in interface_config %}
    {%- set address = interface_config.get('pseudo_ip4') %}
    {%- if address is not none and address.startswith(nat64_range) %}
    {{ address }}: {{ salt['os_network.strip_cidr'](interface_config['ip6']) }}
    {%- endif %} {#- close address check #}
    {%- endif %} {#- close ip6 check #}
    {%- endfor %} {#- close interfaces loop #}
    {%- endfor %} {#- close hosts loop #}
    172.16.164.5: 2a07:de40:b27e:1204::10
