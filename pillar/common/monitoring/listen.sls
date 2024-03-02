{#- exporter listen address priority:
    hosts.yaml file (modern VMs) -> id pillar (bare metal and special VMs) -> DNS (VMs in legacy networks) #}
{%- set address = salt['saltutil.runner']('os_pillar.get_host_ip6', arg=[grains['host'], True]) -%}
{%- if address is none %}
{%- set records = salt['dnsutil.A'](grains['id']) %}
{%- if records %}
{%- set address = records[0] %}
{%- else %}
{%- set address = none %}
{%- endif %}
{%- endif %}

{%- if address is not none %}
prometheus:
  pkg:
    component:
      {%- for exporter, port in {
            'node': 9100,
            'ping': 9427,
          }.items()
      %}
      {{ exporter }}_exporter:
        environ:
          args:
            web.listen-address: '{{ address | ipwrap }}:{{ port }}'
      {%- endfor %}
{%- endif %}
