{#- node_exporter listen address priority: hosts.yaml file (modern VMs) -> id pillar (bare metal and special VMs) -> DNS (VMs in legacy networks) #}
{%- set address = salt['saltutil.runner']('os_pillar.get_host_ip6', arg=[grains['host'], True]) -%}
{%- if address is none %}
{%- set records = salt['dnsutil.A'](grains['id']) %}
{%- if records %}
{%- set address = records[0] %}
{%- else %}
{%- set address = none %}
{%- endif %}
{%- endif %}

prometheus:
  wanted:
    component:
      node_exporter:
        name: golang-github-prometheus-node_exporter

  pkg:
    component:
      node_exporter:
        environ:
          args:
            {%- if address is not none %}
            web.listen-address: '{{ address | ipwrap }}:9100'
            {%- endif %}
            collector.filesystem.fs-types-exclude: "'^(\
                tmpfs\
                |cgroup2?\
                |debugfs\
                |devpts\
                |devtmpfs\
                |fusectl\
                |overlay\
                |proc\
                |procfs\
                |pstore\
              )$'"
            collector.netdev.device-exclude: "'^d-o?s-[a-z]+$'"
            collector.zfs: false
            collector.thermal_zone: false
            collector.powersupplyclass: false
