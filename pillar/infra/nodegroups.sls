{%- import_yaml 'infra/clusters.yaml' as clusters %}

salt:
  master:
    nodegroups:
      {%- for cluster, cluster_config in clusters.items() %}
      {{ cluster }}:
        {%- for node in cluster_config['nodes'] %}
        - {{ node }}.infra.opensuse.org
        {%- endfor %}
      {%- endfor %}
      hypervisors: N@{{ ' and N@'.join(clusters.keys()) }}
      asgard:
        - asgard1.infra.opensuse.org
        - asgard2.infra.opensuse.org
      atlas:
        - atlas1.infra.opensuse.org
        - atlas2.infra.opensuse.org
      galera:
        - galera1.infra.opensuse.org
        - galera2.infra.opensuse.org
        - galera3.infra.opensuse.org
      hel:
        - hel1.infra.opensuse.org
        - hel2.infra.opensuse.org
      dns:
        - prg-ns1.infra.opensuse.org
        - prg.ns2.infra.opensuse.org
        - provo-ns.infra.opensuse.org
        - qsc-ns3.infra.opensuse.org
      dns-prg:
        - prg-ns1.infra.opensuse.org
        - prg.ns2.infra.opensuse.org
      mail:
        {%- for i in [1, 2, 3, 4] %}
        - mx{{ i }}.infra.opensuse.org
        {%- endfor %}
      mail-prg:
        - mx1.infra.opensuse.org
        - mx2.infra.opensuse.org
      mirrordb:
        - mirrordb1.infra.opensuse.org
        - mirrordb2.infra.opensuse.org
      narwal:
        - ipx-narwal1.infra.opensuse.org
        {%- for i in [4, 5, 6, 7, 8] %}
        - narwal{{ i }}.infra.opensuse.org
        {%- endfor %}
