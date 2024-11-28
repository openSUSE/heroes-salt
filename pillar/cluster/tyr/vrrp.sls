include:
  - common.keepalived.scripts.haproxy

{%- if grains['id'] == 'tyr1.infra.opensuse.org' %}
{%- set config = {
      'state': 'MASTER',
      'priority': 100,
      'src': '2a07:de40:617e:1903::11'
    }
%}

{%- elif grains['id'] == 'tyr2.infra.opensuse.org' %}
{%- set config = {
      'state': 'BACKUP',
      'priority': 50,
      'src': '2a07:de40:617e:1903::12'
    }
%}

{%- else %}
  {%- do salt.log.error('tyr: illegal minion in cluster') %}
  {%- set config = {'state': None, 'priority': 0, 'src': None} %}
{%- endif %}

keepalived:
  config:
    global_defs:
      router_id: tyr
      enable_script_security: true
    vrrp_instance:
      tyr:
        mcast_src_ip: {{ config['src'] }}
        priority: {{ config['priority'] }}
        state: {{ config['state'] }}
        advert_int: 1
        interface: os-internal
        virtual_router_id: 10
        smtp_alert: true
        virtual_ipaddress:
          - 2a07:de40:617e:1903::10 dev os-internal
        track_interface:
          - os-internal
          - d-os-internal
        track_script:
          - check_haproxy_service
          - check_haproxy_status

network:
  interfaces:
    d-os-internal:
      bootproto: none
      interfacetype: dummy
      startmode: auto
