{#- source infrastructure data #}
{%- import_yaml 'infra/hosts.yaml' as hosts %}
{%- import_yaml 'infra/networks.yaml' as country_networks %}
{%- import_yaml 'infra/nameservers.yaml' as country_nameservers %}

{#- set generic variables #}
{%- set host = grains['host'] %}
{%- set country = grains.get('country') %}
{%- set networks = country_networks.get(country, {}) %}

{#- locations without internal IPv6 routing (https://progress.opensuse.org/issues/151192) #}
{%- set legacy_countries = ['de', 'us'] %}
{#- gateway machines which have internal IPv6 routing, as opposed to other machines in the legacy countries #}
{%- set legacy_excludes = {'de': ['stonehat'], 'us': ['provo-gate']} %}
{%- set ip6_gw = grains['ip6_gw'] %}

{%- set msg = 'common.network, host ' ~ host ~ ': ' %}
{%- set log = salt.log.debug %}

{#- check if machine needs modern or legacy IP configuration #}
{%- if country in legacy_countries and not host in legacy_excludes.get(country, []) and ip6_gw %}
{%- set do_legacy = True %}
{%- else %}
{%- set do_legacy = False %}
{%- endif %}
{%- do log(msg ~ 'do_legacy: ' ~ do_legacy) %}

{#- start main logic if the minion is listed in hosts.yaml, otherwise none of the below will be executed #}
{%- if host in hosts %}

{#- fetch host specific configuration from hosts.yaml #}
{%- set hostconfig = hosts[host] %}
{%- set interfaces = hostconfig.get('interfaces', {}) %}

{#- assess the primary network interface, which decides the main network segment #}
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

{#- if an interface starts with "os-", it is named using our common naming scheme which indicates the short network segment name #}
{%- if primary_interface.startswith('os-') %}
{%- set shortnet = primary_interface %}

{#- otherwise, assess the network segment based off the source (hypervisor) interface #}
{%- else %}
{%- set shortnet = interfaces[primary_interface].get('source', '').replace('x-', '') %}
{%- endif %}
{%- do log(msg ~ 'shortnet set to ' ~ shortnet) %}
{%- set reduced_interfaces = interfaces.pop(primary_interface) %}

{#- if no primary interface is available, find and apply addresses defined outside of an "interfaces" block (single interface hosts might use this) #}
{%- else %}
{%- do log(msg ~ 'trying to use generic interface addresses') %}
{%- set ip4 = hostconfig.get('ip4') %}
{%- set ip6 = hostconfig.get('ip6') %}
{%- set reduced_interfaces = {} %}
{%- set shortnet = None %}

{%- endif %} {#- close primary interface check #}

{%- do log(msg ~ 'primary IPv4 address set to ' ~ ip4) %}
{%- do log(msg ~ 'primary IPv6 address set to ' ~ ip6) %}

{%- else %} {#- machine not in hosts, in an unmanaged location, or bare metal #}
{%- do log('common.network: no host entry for ' ~ host) %}
{%- set ip4 = None %}
{%- set ip6 = None %}
{%- set shortnet = None %}
{%- set reduced_interfaces = {} %}
{%- endif %} {#- close host in hosts check #}

{#- configure interfaces if the previous logic found any with usable IP addresses #}
{%- if country in country_nameservers or ip4 is not none or ip6 is not none or reduced_interfaces or do_legacy %}
network:

{%- if ip4 is not none or ip6 is not none or reduced_interfaces %}
  interfaces:

    {#- configure addresses on the primary interface if IP addresses were found for it #}
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

    {#- configure addresses on any additional interfaces if IP addresses were found for them #}
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

{%- endif %} {#- close inner ip4/ip6/reduced_interfaces check #}

{#- if a main network segment is available or legacy IP configuration is enabled, configure routes #}
{%- if shortnet or do_legacy %}
{%- set net_ns = namespace(network=None) %}
{#- find the network segment matching the previously assessed short name #}
{%- for network, config in networks.items() %}
{%- if config['short'] == shortnet %}
{%- set net_ns.network = network %}
{#- segment names only occur once, hence stop the iteration after the first match #}
{%- break %}
{%- endif %}
{%- endfor %}
{%- do log(msg ~ 'network set to ' ~ net_ns.network) %}
{%- set network = networks.get(net_ns.network, {}) %}

{#- if gateway entries for the respective segment were found, configure them as default routes #}
{%- if 'gw4' in network or 'gw6' in network or do_legacy %}
  routes:
    {%- if ip4 is not none and 'gw4' in network %}
    default4:
      gateway: '{{ network['gw4'] }}'
    {%- endif %}
    {%- if ip6 is not none and 'gw6' in network %}
    default6:
      gateway: '{{ network['gw6'] }}'
    {%- endif %}

    {%- if do_legacy %}           {#- v PRG2 NAT64      v PRG2 os-public   v ???               v ???               v ??? #}
    {%- set common_destinations = ['172.16.164.0/24', '172.16.130.0/24', '192.168.252.0/24', '192.168.253.0/24', '192.168.254.0/24'] %}

    {#- install default routes on machines in Provo which use external default gateways #}
    {%- if country == 'us' %}        {#- v NUE QSC #}
    {%- do common_destinations.append('192.168.87.0/24') %}
    default4:
      gateway: 91.193.113.94
    default6:
      gateway: 2a07:de40:401::1
    {#- install legacy internal routes through provo-gate on such machines #}
    {%- for destination_network in common_destinations %}
    {{ destination_network }}:
      gateway: 192.168.67.20
    {%- endfor %}

    {%- elif country == 'de' %}      {# v PRV              v os-p2p-nue1/1    v os-p2p-nue1/2 #}
    {%- do common_destinations.extend(['192.168.67.0/24', '172.16.201.0/31', '172.16.202.0/31']) %}
    {#- install default routes on machines in Nuremberg (QSC) which use external default gateways #}
    default4:
      gateway: 62.146.92.201
    default6:
      gateway: 2a01:138:a004::1
    {#- install legacy internal routes through stonehat on such machines #}
    {%- for destination_network in common_destinations %}
    {{ destination_network }}:
      gateway: 192.168.87.1
    {%- endfor %}

    {%- endif %} {#- close country check #}

    {#-
      for machines in locations we have not yet equipped with internal IPv6 routing,
      but which have an IPv6 route to the internet, install a blackhole route to our os-internal, os-kani and os-salt networks in PRG2
      this allows machines in these locations which have an IPv6 route to the internet to communicate with internal
      services in PRG2 via IPv4 instead of sending affected packets to the internet
      (which either leads to timeouts or stuck sessions, since we do not allow internal services to be reached over the internet)
    #}
    {%- for prefix in [
          '2a07:de40:b27e:1200::',
          '2a07:de40:b27e:1203::',
          '2a07:de40:b27e:1210::',
    ] %}
    {{ prefix }}/64:
      options:
        - blackhole
    {%- endfor %} {#- close prefix loop #}
    {%- endif %} {#- close do_legacy check #}
{%- endif %} {#- close network check #}
{%- endif %} {#- close shortnet check #}

{#- configure nameservers if any managed ones are available for the location the minion is in #}
{%- if country in country_nameservers %}
  config:
    netconfig_dns_static_servers:
      {%- for nameserver in country_nameservers[country] %}
      - {{ nameserver }}
      {%- endfor %}
    netconfig_dns_static_searchlist: infra.opensuse.org
{%- endif %}

{%- endif %} {#- close country/ip4/ip6/reduced_interfaces check #}
