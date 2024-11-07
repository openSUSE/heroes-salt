{%- if grains['id'] == 'avalon1.infra.opensuse.org' %}
{%- set mode = 'master' %}
{%- elif grains['id'] == 'avalon2.infra.opensuse.org' %}
{%- set mode = 'backup' %}
{%- else %}
{%- do salt.log.error('avalon: illegal minion in cluster') %}
{%- set mode = None %}
{%- endif %}

{%- from 'macros.jinja' import gateway_vrrp, gateway_vrrp_networks %}

{%- set srcips = {
          'master': {
            'ip4': '172.16.112.1',
            'ip6': 'fd03:7bbf:d626:1700::1',
          },
          'backup': {
            'ip4': '172.16.112.2',
            'ip6': 'fd03:7bbf:d626:1700::2',
          },
        }
%}

keepalived:
  config:
    global_defs:
      router_id: avalon
      enable_script_security: true
    vrrp_instance:
      {{ gateway_vrrp_networks('avalon', mode, srcips, 'slc1') }}

      {{ gateway_vrrp('avalon', mode, srcips, 'os-p2p-pub', '2a07:de40:617f:201::1/64', 253) }}
      {{ gateway_vrrp('avalon', mode, srcips, 'os-p2p-pub', '195.135.220.41/29',        254, true) }}

network:
  interfaces:
    d-os-p2p-pub:
      bootproto: none
      interfacetype: dummy
      startmode: auto
