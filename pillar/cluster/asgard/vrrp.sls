{%- if grains['id'] == 'asgard1.infra.opensuse.org' %}
{%- set mode = 'master' %}
{%- elif grains['id'] == 'asgard2.infra.opensuse.org' %}
{%- set mode = 'backup' %}
{%- else %}
{%- do salt.log.error('asgard: illegal minion in cluster') %}
{%- set mode = None %}
{%- endif %}

{%- from 'macros.jinja' import gateway_vrrp, gateway_vrrp_networks %}

{%- set srcips = {
          'master': {
            'ip4': '172.16.128.1',
            'ip6': 'fd4b:5292:d67e:1000::1',
           },
           'backup': {
             'ip4': '172.16.128.2',
             'ip6': 'fd4b:5292:d67e:1000::2',
           },
        }
%}

keepalived:
  config:
    global_defs:
      router_id: asgard
      enable_script_security: true
    vrrp_instance:
      {{ gateway_vrrp_networks('asgard', mode, srcips, 'prg2', true) }}

      {{ gateway_vrrp('asgard', mode, srcips, 'os-p2p-pub', '2a07:de40:b27f:201::1/64', 253) }}
      {{ gateway_vrrp('asgard', mode, srcips, 'os-p2p-pub', '195.135.223.41/29',        254, true) }}

network:
  interfaces:
    d-os-p2p-pub:
      bootproto: none
      interfacetype: dummy
      startmode: auto
