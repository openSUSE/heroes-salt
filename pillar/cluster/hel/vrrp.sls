{%- if grains['id'] == 'hel1.infra.opensuse.org' %}
{%- set config = {
      'state': 'MASTER',
      'priority': 100,
      'src': '2a07:de40:b27e:1203::11'
    }
%}

{%- elif grains['id'] == 'hel2.infra.opensuse.org' %}
{%- set config = {
      'state': 'BACKUP',
      'priority': 50,
      'src': '2a07:de40:b27e:1203::12'
    }
%}

{%- else %}
{%- do salt.log.error('hel: illegal minion in cluster') %}
{%- set config = {'state': None, 'priority': 0, 'src': None} %}
{%- endif %}

keepalived:
  config:
    global_defs:
      router_id: hel
      enable_script_security: true
    vrrp_instance:
      hel:
        mcast_src_ip: {{ config['src'] }}
        priority: {{ config['priority'] }}
        state: {{ config['state'] }}
        advert_int: 1
        interface: os-internal
        virtual_router_id: 10
        smtp_alert: true
        virtual_ipaddress:
          - 2a07:de40:b27e:1203::10 dev os-internal
        track_interface:
          - os-internal
          - d-os-internal

network:
  interfaces:
    d-os-internal:
      bootproto: none
      interfacetype: dummy
      startmode: auto
