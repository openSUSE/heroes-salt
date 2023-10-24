{%- if grains['id'] == 'asgard1.infra.opensuse.org' %}
{%- set mode = 'master' %}
{%- elif grains['id'] == 'asgard2.infra.opensuse.org' %}
{%- set mode = 'backup' %}
{%- else %}
{%- do salt.log.error('asgard: illegal minion in cluster') %}
{%- set mode = None %}
{%- endif %}

{%- from 'cluster/asgard/macros.jinja' import vrrp with context %}

keepalived:
  config:
    global_defs:
      router_id: asgard
      enable_script_security: true
    vrrp_instance:
      {{ vrrp('os-salt',      '2a07:de40:b27e:1200::/64', 200) }}
      {{ vrrp('os-bare',      '2a07:de40:b27e:1201::/64', 201) }}
      {{ vrrp('os-ipmi-r',    '2a07:de40:b27e:1202::/64', 202) }}
      {{ vrrp('os-internal',  '2a07:de40:b27e:1203::/64', 203) }}
      {{ vrrp('os-internal',  '172.16.129.3/24',          129, true) }}
      {{ vrrp('os-public',    '2a07:de40:b27e:1204::/64', 204) }}
      {{ vrrp('os-public',    '172.16.130.3/24',          130, true) }}
      {{ vrrp('os-mirror',    '2a07:de40:b27e:1205::/64', 205) }}
      {{ vrrp('os-thor',      '2a07:de40:b27e:1100::/64', 100) }}
      {{ vrrp('os-thor',      '172.16.128.3/24',          120, true) }}
      {{ vrrp('os-s-warp',    '2a07:de40:b27e:1101::/64', 101) }}
      {{ vrrp('os-p2p-pub',   '2a07:de40:b27f:201::1/64', 253) }}
      {{ vrrp('os-p2p-pub',   '195.135.223.41/29',        254, true) }}
