include:
  - common.keepalived.scripts.haproxy
  - common.keepalived.scripts.https

{%- if grains['id'] == 'globus1.infra.opensuse.org' %}
  {%- set config = {
        'state': 'MASTER',
        'priority': 100,
        'src4': '172.16.113.11',
        'src6': '2a07:de40:617e:1904::11'
      }
  %}

{%- elif grains['id'] == 'globus2.infra.opensuse.org' %}
  {%- set config = {
        'state': 'BACKUP',
        'priority': 50,
        'src4': '172.16.113.12',
        'src6': '2a07:de40:617e:1904::12'
      }
  %}

{%- else %}
  {%- do salt.log.error('globus: illegal minion in cluster') %}
  {%- set config = {'state': None, 'priority': 0, 'src4': None, 'src6': None} %}
{%- endif %}

{%- set vips = {'vip4': '172.16.113.10', 'vip6': '2a07:de40:617e:1904::10'} %}

keepalived:
  config:
    global_defs:
      router_id: globus
      enable_script_security: true
    vrrp_instance:
      {%- for instance in [4, 6] %}
      globus{{ '-legacy' if instance == 4 else '' }}:
        mcast_src_ip: {{ config['src' ~ instance] }}
        priority: {{ config['priority'] }}
        state: {{ config['state'] }}
        advert_int: 1
        interface: os-public
        virtual_router_id: 9{{ loop.index }}
        smtp_alert: true
        virtual_ipaddress:
          - {{ vips['vip' ~ instance] }} dev os-public
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
