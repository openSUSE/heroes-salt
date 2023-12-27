{#- construct short name from ID, the hosts grain might not be correct yet -#}
{%- set id = grains['id'] -%}
{%- set id_host = id.split('.')[0] -%}

{#- try hosts.yaml lookup -#}
{%- set address6 = salt['saltutil.runner']('os_pillar.get_host_ip6', arg=[id_host, True]) -%}
{%- set address4 = salt['saltutil.runner']('os_pillar.get_host_ip4', arg=[id_host, True]) -%}

{#- if not successful, try grains lookup -#}
{#- IPv4, based on private addresses -#}
{%- if not address4 and not address6 and not 'Router' in grains.get('hostusage', []) -%}
  {%- set ipv4_ns = namespace(address=None) -%}
  {%- for address in grains['ipv4'] -%}
    {%- if salt['network.is_private'](address) and not salt['network.is_loopback'](address) -%}
      {%- set ipv4_ns.address = address -%}
      {%- continue -%}
    {%- endif -%}
  {%- endfor -%}
  {%- set address4 = ipv4_ns.address -%}
{%- endif -%}

{#- IPv6, based on addresses in known-good prefixes -#}
{%- if not address6 -%}
  {#- cidr needs to be expanded once full IPv6 is rolled out in other locations -#}
  {%- set ipv6_ns = namespace(address=None) -%}
  {%- for address in grains['ipv6'] -%}
    {%- if salt['network.ip_in_subnet'](address, '2a07:de40:b27e::/48') -%}
      {%- set ipv6_ns.address = address -%}
      {%- continue -%}
    {%- endif -%}
  {%- endfor -%}
  {%- set address6 = ipv6_ns.address -%}
{%- endif -%}

{#- set hosts entries if addresses were found -#}
{%- if address4 or address6 %}
hostsfile:
  only:
    {%- if address6 %}
    {{ address6 }}:
      - {{ id }}
      - {{ id_host }}
    {%- endif %}
    {%- if address4 %}
    {{ address4 }}:
      - {{ id }}
      - {{ id_host }}
    {%- endif %}
{%- endif %}
