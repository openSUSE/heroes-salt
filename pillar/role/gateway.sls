nftables: true

{%- import_yaml 'infra/hosts.yaml' as hosts %}

{%- import_yaml 'infra/networks.yaml' as networks %}
{%- set pseudo_networks = networks.pop('pseudo') %}

hosts:
  {%- for host, host_config in hosts.items() %}
  {{ host }}:
    {%- set minion_id_struct = salt['slsutil.renderer']('/srv/pillar/id/' ~ host ~ '_infra_opensuse_org.sls') %}
    site: {{ minion_id_struct['grains']['site'] }}
    roles: {{ minion_id_struct.get('roles', []) }}
    interfaces: {{ host_config['interfaces'] }}
  {%- endfor %}

networks:
  sites: {{ networks }}
  pseudos: {{ pseudo_networks }}

{%- set export_networks = {
          'prg2': {'v4': [], 'v6': []},
          'slc1': {'v4': [], 'v6': []},
        }
%}

{%- for site, site_networks in networks.items() %}
  {%- do site_networks.update(pseudo_networks.get(site, {})) %}
  {%- for network, network_config in site_networks.items() %}
    {%- if network_config.get('export', false) is sameas true %}
      {%- do export_networks[site]['v6'].append(network_config['net6']) %}
      {%- if 'net4' in network_config %}
        {%- do export_networks[site]['v4'].append(network_config['net4']) %}
      {%- endif %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}

bird:
  server:
    definitions:
      openSUSE_VRRP_Primary_Networks:
        include: /run/birdalived/output_bird_vrrp_primary_networks
    {%- for site, networks in export_networks.items() %}
      {%- set site = site | upper %}
      openSUSE_{{ site }}_Networks: {{ networks['v6'] }}
      {%- if networks['v4'] %}
      openSUSE_{{ site }}_Networks_Legacy: {{ networks['v4'] }}
      {%- endif %}
    {%- endfor %}
    logs:
      syslog: all
    watchdogs:
      warning: 5 s
      timeout: 30 s
    protocols:
      direct:
        ipv4: null
        ipv6: null
      {%- for i in [6, 4] %}
      kernel_{{ i }}:
        type: kernel
        ipv{{ i }}:
          filters:
            export:
              - openSUSE_direct
      {%- endfor %}

keepalived:
  config:
    global_defs:
      fifo_write_vrrp_states_on_reload: true
      vrrp_notify_fifo: /run/birdalived/pipe

profile:
  conntrack:
    hashsize: 524288

zypper:
  packages:
    conntrackd: {}
    nftables: {}
    # for scripts under salt/profile/ha/files/bird/
    perl-BerkeleyDB: {}
    vnstat: {}

sysctl:
  params:
    net.core.rmem_default: 425984
    net.core.rmem_max: 638976
    net.ipv4.ip_forward: 1
    net.ipv6.conf.all.forwarding: 1
    net.netfilter.nf_conntrack_tcp_loose: 0
