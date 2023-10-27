{%- import_yaml 'infra/hosts.yaml' as hosts %}
{%- import_yaml 'infra/networks.yaml' as country_networks %}
{%- import_yaml 'infra/nameservers.yaml' as country_nameservers %}

{%- set host = grains['host'] %}
{%- set country = grains.get('country') %}
{%- set networks = country_networks.get(country, {}) %}

{%- set msg = 'common.network, host ' ~ host ~ ': ' %}
{%- set log = salt.log.debug %}

{%- if host in hosts %}

{%- set hostconfig = hosts[host] %}
{%- set interfaces = hostconfig.get('interfaces', {}) %}

{%- if 'primary_interface' in hostconfig %}
{%- set primary_interface = hostconfig['primary_interface'] %}
{%- elif interfaces | length == 1 %}
{%- set primary_interface = interfaces.keys() | first  %}
{%- else %}
{%- set primary_interface = 'eth0' %}
{%- endif %} {#- close primary_interface check #}

{%- do log(msg ~ 'primary interface set to ' ~ primary_interface) %}

{#- apply IP addresses from preferred interface #}
{%- if primary_interface in interfaces and ( 'ip4' in interfaces[primary_interface] or 'ip6' in interfaces[primary_interface] ) %}
{%- do log(msg ~ 'trying to use primary interface addresses') %}
{%- set ip4 = interfaces[primary_interface].get('ip4') %}
{%- set ip6 = interfaces[primary_interface].get('ip6') %}
{%- if primary_interface.startswith('os-') %}
{%- set shortnet = primary_interface %}
{%- else %}
{%- set shortnet = interfaces[primary_interface].get('source', '').replace('x-', '') %}
{%- endif %}
{%- do log(msg ~ 'shortnet set to ' ~ shortnet) %}
{%- set reduced_interfaces = interfaces.pop(primary_interface) %}

{#- otherwise apply its global addresses (single interface hosts without an "interfaces" configuration) #}
{%- else %}
{%- do log(msg ~ 'trying to use generic interface addresses') %}
{%- set ip4 = hostconfig.get('ip4') %}
{%- set ip6 = hostconfig.get('ip6') %}
{%- set reduced_interfaces = {} %}
{%- set shortnet = None %}

{%- endif %} {#- close primary interface check #}

{%- do log(msg ~ 'primary IPv4 address set to ' ~ ip4) %}
{%- do log(msg ~ 'primary IPv6 address set to ' ~ ip6) %}

{%- if ip4 is not none or ip6 is not none or reduced_interfaces %}
network:
  interfaces:

    {%- if ip4 is not none or ip6 is not none %}
    {{ primary_interface }}:
      addresses:
        {%- if ip4 is not none %}
        - {{ ip4 }}
        {%- endif %}
        {%- if ip6 is not none %}
        - {{ ip6 }}
        {%- endif %}
    {%- endif %}

    {%- for interface, ifconfig in reduced_interfaces.items() %}
    {%- if 'ip4' in ifconfig or 'ip6' in ifconfig %}
    {%- do log(msg ~ ' configuring additional interface ' ~ interface) %}
    {{ interface }}:
      addresses:
        {%- if 'ip4' in ifconfig %}
        - {{ ifconfig['ip4'] }}
        {%- endif %}
        {%- if 'ip6' in ifconfig %}
        - {{ ifconfig['ip6'] }}
        {%- endif %}
    {%- endif %} {#- close ip4/ip6 check #}
    {%- endfor %}

{%- if shortnet %}
{%- set net_ns = namespace(network=None) %}
{%- for network, config in networks.items() %}
{%- if config['short'] == shortnet %}
{%- set net_ns.network = network %}
{%- break %}
{%- endif %}
{%- endfor %}
{%- do log(msg ~ 'network set to ' ~ net_ns.network) %}
{%- set network = networks.get(net_ns.network, {}) %}

{%- if 'gw4' in network or 'gw6' in network %}
  routes:
    {%- if ip4 is not none and 'gw4' in network %}
    default4:
      gateway: '{{ network['gw4'] }}'
    {%- endif %}
    {%- if ip6 is not none and 'gw6' in network %}
    default6:
      gateway: '{{ network['gw6'] }}'
    {%- endif %}
{%- endif %} {#- close network check #}
{%- endif %} {#- close shortnet check #}

  {%- if country in country_nameservers %}
  config:
    netconfig_dns_static_servers:
      {%- for nameserver in country_nameservers[country] %}
      - {{ nameserver }}
      {%- endfor %}
    netconfig_dns_static_searchlist: infra.opensuse.org
  {%- endif %}

{%- endif %} {#- close ip4/ip6/reduced_interfaces check #}
{%- else %}
{%- do log('common.network: no host entry for ' ~ host) %}
{%- endif %} {#- close host in hosts check #}
