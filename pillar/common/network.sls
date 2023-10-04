{%- import_yaml 'infra/hosts.yaml' as hosts %}
{%- set host = grains['host'] %}
{%- set msg = 'common.network, host ' ~ host ~ ': ' %}
{%- set log = salt.log.debug %}

{%- if host in hosts %}

{%- set hostconfig = hosts[host] %}
{%- set interfaces = hostconfig.get('interfaces', {}) %}
{%- set primary_interface = hostconfig.get('primary_interface', 'eth0') %}
{%- do log(msg ~ 'primary interface set to ' ~ primary_interface) %}

{#- apply IP addresses from preferred interface #}
{%- if primary_interface in interfaces and ( 'ip4' in interfaces[primary_interface] or 'ip6' in interfaces[primary_interface] ) %}
{%- do log(msg ~ 'trying to use primary interface addresses') %}
{%- set ip4 = interfaces[primary_interface].get('ip4') %}
{%- set ip6 = interfaces[primary_interface].get('ip6') %}
{%- set reduced_interfaces = interfaces.pop(primary_interface) %}

{#- otherwise apply its global addresses (single interface hosts without an "interfaces" configuration) #}
{%- else %}
{%- do log(msg ~ 'trying to use generic interface addresses') %}
{%- set ip4 = hostconfig.get('ip4') %}
{%- set ip6 = hostconfig.get('ip6') %}
{%- set reduced_interfaces = {} %}

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

{%- endif %} {#- close ip4/ip6/reduced_interfaces check #}
{%- else %}
{%- do log('common.network: no host entry for ' ~ host) %}
{%- endif %} {#- close host in hosts check #}
