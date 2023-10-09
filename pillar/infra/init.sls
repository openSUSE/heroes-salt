{%- set clusterfile = '/clusters.yaml' -%}
{%- set hostsfile = '/hosts.yaml' -%}

infrastructure:
  domains:
    infra.opensuse.org:
      clusters:
      {%- import_yaml slspath ~ '/clusters.yaml' as clusters %}
        {%- for cluster, clusterconfig in clusters.items() %}
        {%- do salt['log.debug']('Parsing cluster ' ~ cluster) %}
        {{ cluster }}:
          {%- if 'primary_node' in clusterconfig %}
          primary: {{ clusterconfig['primary_node'] }}
          {%- endif %}
          {%- if 'netapp' in clusterconfig %}
          netapp:
            host: {{ clusterconfig['netapp']['host'] }}
            vs_primary: {{ clusterconfig['netapp']['vs_primary'] }}
            {%- if 'vs_secondary' in clusterconfig['netapp'] %}
            vs_secondary: {{ clusterconfig['netapp']['vs_secondary'] }}
            {%- endif %}
            igroup_primary: {{ clusterconfig['netapp']['igroup_primary'] if 'igroup_primary' in clusterconfig['netapp'] else cluster }}
          {%- endif %}
          {%- if 'storage' in clusterconfig %}
          storage: {{ clusterconfig['storage'] }}
          {%- endif %}
        {%- endfor %}
      machines:
      {%- import_yaml slspath ~ '/hosts.yaml' as hosts %}
        {%- for host, hostconfig in hosts.items() %}
        {%- do salt['log.debug']('Parsing host ' ~ host) %}
        {{ host }}:
          cluster: {{ hostconfig['cluster'] }}
          {%- if 'node' in hostconfig %}
          node: {{ hostconfig['node'] }}
          {%- endif %}
          {%- if 'eth0' in hostconfig['interfaces'] -%}
          {%- set ip4 = hostconfig['interfaces']['eth0'].get('ip4') %}
          {%- set ip6 = hostconfig['interfaces']['eth0'].get('ip6') %}
          {%- else %}
          {%- set ip4 = hostconfig.get('ip4') %}
          {%- set ip6 = hostconfig.get('ip6') %}
          {%- endif %}
          {%- if ip4 is not none %}
          ip4: {{ ip4 }}
          {%- endif %}
          {%- if ip6 is not none %}
          ip6: {{ ip6 }}
          {%- endif %}
          interfaces:
            {%- for interface, ifconfig in hostconfig['interfaces'].items() %}
            {%- set iftype = ifconfig.get('type', 'direct') %}
            {{ interface }}:
              mac: '{{ ifconfig['mac'] }}'
              type: '{{ iftype }}'
              source: '{{ ifconfig['source'] }}'
              {%- if iftype == 'direct' %}
              mode: '{{ ifconfig.get('mode', 'bridge') }}'
              {%- endif %}
              {%- if 'ip4' in ifconfig %}
              ip4: '{{ ifconfig['ip4'] }}'
              {%- endif %}
              {%- if 'ip6' in ifconfig %}
              ip6: '{{ ifconfig['ip6'] }}'
              {%- endif %}
            {%- endfor %}
          ram: {{ hostconfig['ram'] }}
          vcpu: {{ hostconfig['vcpu'] }}
          {%- if hostconfig['disks'] is defined %}
          disks:
            {%- for disk, size in hostconfig['disks'].items() %}
            {{ disk }}: {{ size }}
            {%- endfor %}
          {%- endif %}
          image: {{ hostconfig.get('image', 'admin-minimal-latest') }}
        {%- endfor %}
