{%- import_yaml 'infra/clusters.yaml' as clusters %}
{%- set site = grains.get('site') %}

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

      {%- if site == 'prg2' %}
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
      prg-ns:
        - prg-ns1.infra.opensuse.org
        - prg-ns2.infra.opensuse.org
      mail-prg:
        - mx1.infra.opensuse.org
        - mx2.infra.opensuse.org
      mirrordb:
        - mirrordb1.infra.opensuse.org
        - mirrordb2.infra.opensuse.org
      narwal:
        - ipx-narwal1.infra.opensuse.org
        {%- for i in [5, 6, 7, 8] %}
        - narwal{{ i }}.infra.opensuse.org
        {%- endfor %}

      {%- elif site == 'slc1' %}
      avalon:
        - avalon1.infra.opensuse.org
        - avalon2.infra.opensuse.org
      globus:
        - globus1.infra.opensuse.org
        - globus2.infra.opensuse.org
      slc-devcon:
        - slc-devcon1.infra.opensuse.org
        - slc-devcon2.infra.opensuse.org
      slc-ns:
        - slc-ns1.infra.opensuse.org
        - slc-ns2.infra.opensuse.org
      slc-warp:
        - slc-warp1.infra.opensuse.org
        - slc-warp2.infra.opensuse.org
      tyr:
        - tyr1.infra.opensuse.org
        - tyr2.infra.opensuse.org
      {%- endif %}
