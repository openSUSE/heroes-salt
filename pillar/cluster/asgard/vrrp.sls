{%- if grains['id'] == 'asgard1.infra.opensuse.org' %}
{%- set mode = 'master' %}
{%- elif grains['id'] == 'asgard2.infra.opensuse.org' %}
{%- set mode = 'backup' %}
{%- else %}
{%- do salt.log.error('asgard: illegal minion in cluster') %}
{%- set mode = None %}
{%- endif %}

{%- from 'cluster/asgard/macros.jinja' import vrrp with context %}
{%- import_yaml 'infra/networks.yaml' as site_networks %}
{%- set networks = site_networks['prg2'] %}

keepalived:
  config:
    global_defs:
      router_id: asgard
      enable_script_security: true
    vrrp_instance:
      {%- for vlan, config in networks.items () %}

      {%- for v in [4, 6] %}
      {%- set net = 'net' ~ v %}
      {%- set gw = 'gw' ~ v %}

      {%- if net in config and gw in config %}

      {%- if v == 4 %}
      {%- set legacy = true %}
      {%- set vrid = config['gw4'].split('.')[2] %}

      {%- elif v == 6 %}
      {%- set legacy = false %}
      {%- set vrid = config['gw6'].split(':')[3][1:] %}
      {%- endif %}

      {{ vrrp(config['short'], salt['os_network.gw_with_cidr'](config[gw], config[net]), vrid, legacy) }}

      {%- endif %} {#- close net/gw check #}
      {%- endfor %} {#- close IP version loop #}
      {%- endfor %} {#- close networks loop #}

      {{ vrrp('os-p2p-pub',   '2a07:de40:b27f:201::1/64', 253) }}
      {{ vrrp('os-p2p-pub',   '195.135.223.41/29',        254, true) }}

network:
  interfaces:
    d-os-p2p-pub:
      bootproto: none
      interfacetype: dummy
      startmode: auto
