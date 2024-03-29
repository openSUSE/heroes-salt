include:
  - common.keepalived.scripts.haproxy
  - common.keepalived.scripts.https

{%- if grains['id'] == 'atlas1.infra.opensuse.org' %}
{%- set config = {
      'state': 'MASTER',
      'priority': 100,
      'src4': '172.16.130.11',
      'src6': '2a07:de40:b27e:1204::11'
    }
%}

{%- elif grains['id'] == 'atlas2.infra.opensuse.org' %}
{%- set config = {
      'state': 'BACKUP',
      'priority': 50,
      'src4': '172.16.130.12',
      'src6': '2a07:de40:b27e:1204::12'
    }
%}

{%- else %}
{%- do salt.log.error('atlas: illegal minion in cluster') %}
{%- set config = {'state': None, 'priority': 0, 'src4': None, 'src6': None} %}
{%- endif %}

{%- set vips = {'vip4': '172.16.130.10', 'vip6': '2a07:de40:b27e:1204::10'} %}
{%- set vips2 = {'vip4': '172.16.130.13', 'vip6': '2a07:de40:b27e:1204::13'} %}
{%- set vips3 = {'vip4': '172.16.130.14', 'vip6': '2a07:de40:b27e:1204::14'} %}
{%- set vip_login = {'vip4': None, 'vip6': '2a07:de40:b27e:1204::7' } %}

keepalived:
  config:
    global_defs:
      router_id: atlas
      enable_script_security: true
    vrrp_instance:
      {%- for instance in [4, 6] %}
      atlas{{ '-legacy' if instance == 4 else '' }}:
        mcast_src_ip: {{ config['src' ~ instance] }}
        priority: {{ config['priority'] }}
        state: {{ config['state'] }}
        advert_int: 1
        interface: os-public
        virtual_router_id: 9{{ loop.index }}
        smtp_alert: true
        virtual_ipaddress:
          - {{ vips['vip' ~ instance] }} dev os-public
          - {{ vips2['vip' ~ instance] }} dev os-public
          - {{ vips3['vip' ~ instance] }} dev os-public
          {%- if instance == 6 %} {#- TODO: better logic for VIPs using only a single address family #}
          - {{ vip_login['vip' ~ instance] }} dev os-public
          {%- endif %}
        track_interface:
          - os-public
          - d-os-public
        track_script:
          - check_haproxy_service
          - check_haproxy_status
          - check_https_port
      {%- endfor %}

network:
  interfaces:
    d-os-public:
      bootproto: none
      interfacetype: dummy
      startmode: auto
