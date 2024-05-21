{#-
This pillar template implements logic to determine the best suitable listening address for Prometheus exporters running on a given minion. By binding to a curated address, we ensure exporters are not exposed to networks other than the one used for connectivity to the monitoring server.
#}

{#- first try:
    query hosts.yaml #}
{%- set address = salt['saltutil.runner']('os_pillar.get_host_ip6', arg=[grains['host'], True]) -%}

{#- second try:
    iterate over FQDN derived addresses and find one in the PRG2 supernet where we can assume machines have only a single relevant IPv6 equipped interface #}
{%- if address is none and grains.get('country') in ['cz', 'de'] %}
  {%- set listen_ns = namespace(address=None) %}

  {#- try 2.1: find an address in os-internal, the network of our monitoring server, for direct/unrouted access #}
  {%- set ip6_addresses = grains['ipv6'] %}
  {%- for ip6_address in ip6_addresses %}
    {%- if salt['network.ip_in_subnet'](ip6_address, '2a07:de40:b27e:1203::/64') %}
      {%- set listen_ns.address = ip6_address %}
      {%- break %}
    {%- endif %}
  {%- endfor %}

  {#- try 2.2: find any other address in routed PRG2 networks #}
  {%- if listen_ns.address is none %}
    {%- set fqdn_addresses = grains['fqdn_ip6'] %}
    {%- for alt_address in fqdn_addresses %}
      {%- if salt['network.ip_in_subnet'](alt_address, '2a07:de40:b27e::/48') -%}
        {%- set listen_ns.address = alt_address %}
        {%- break %}
      {%- endif %}
    {%- endfor %}
  {%- endif %}

  {%- set address = listen_ns.address %}
{%- endif %}

{#- third try:
    query DNS for A records, this works for machines in legacy sites (Nuremberg, Provo) #}
{%- if address is none %}
  {%- set records = salt['dnsutil.A'](grains['id']) %}
  {%- if records %}
    {%- set address = records[0] %}
  {%- endif %}
{%- endif %}

{#- no further attempts - if all of the above did not yield any results, "address" will stll be "none" and the exporters will bind to all interfaces #}

{%- if address is not none %}
prometheus:
  pkg:
    component:
      {%- for exporter, port in {
            'node': 9100,
            'apache': 9117,
            'hacluster': 9664,
            'pgbouncer': 9127,
            'ping': 9427,
            'postgres': 9187,
            'smartctl': 9633,
          }.items()
      %}
      {{ exporter }}_exporter:
        environ:
          args:
            web.listen-address: '{{ address | ipwrap }}:{{ port }}'
      {%- endfor %}
{%- endif %}
