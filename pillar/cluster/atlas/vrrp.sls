{%- if grains['id'] == 'atlas1.infra.opensuse.org' %}
{%- set mode = 'master' %}
{%- elif grains['id'] == 'atlas2.infra.opensuse.org' %}
{%- set mode = 'backup' %}
{%- else %}
{%- do salt.log.error('atlas: illegal minion in cluster') %}
{%- set mode = None %}
{%- endif %}

keepalived:
  config:
    global_defs:
      router_id: atlas
      enable_script_security: true
    vrrp_instance:
      atlas:
        {%- if mode == 'master' %}
        mcast_src_ip: 2a07:de40:b27e:1204::11
        state: MASTER
        priority: 100
        {%- elif mode == 'backup' %}
        mcast_src_ip: 2a07:de40:b27e:1204::12
        state: BACKUP
        priority: 50
        {%- endif %} {#- close master/backup logic #}
        advert_int: 0.5
        interface: os-public
        virtual_router_id: 1
        smtp_alert: true
        virtual_ipaddress:
          - 2a07:de40:b27e:1204::10 dev os-public
        track_interface:
          - os-public
          - d-os-public

network:
  interfaces:
    d-os-public:
      bootproto: none
      interfacetype: dummy
      startmode: auto
