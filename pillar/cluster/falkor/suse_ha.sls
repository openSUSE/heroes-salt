suse_ha:
  cluster:
    name: falkor
  constraints:
    {%- for vmpair in [
          'atlas',
          'gitlab-runner',
          'hel',
          'kani',
          'mirrordb',
          'mx',
          'prg-monitor',
          'prg-ns',
        ]
    %}
    colo_{{ vmpair }}:
      type: rsc_colocation
      score: -100  # negative score to prefer having the VM resources _not_ run on the same node
      resources:
        - VM_{{ vmpair }}1.infra.opensuse.org
        - VM_{{ vmpair }}2.infra.opensuse.org
    {%- endfor %}
    colo_galera:
      type: rsc_colocation
      score: -100
      sets:
        colo_galera-0:
          VM_galera1.infra.opensuse.org: {}
          VM_galera2.infra.opensuse.org: {}
          VM_galera3.infra.opensuse.org: {}
    colo_narwal:
      type: rsc_colocation
      score: -100
      sets:
        colo_narwal-0:
          VM_narwal5.infra.opensuse.org: {}
          VM_narwal6.infra.opensuse.org: {}
          VM_narwal7.infra.opensuse.org: {}
          VM_narwal8.infra.opensuse.org: {}

    {%- macro resource_set(group) %}
        - resources:

        {%- if group == 'dns' %}
            - VM_hel1.infra.opensuse.org
            - VM_hel2.infra.opensuse.org
            - VM_prg-ns1.infra.opensuse.org
            - VM_prg-ns2.infra.opensuse.org
          sequential: false

        {%- elif group == 'mysql' %}
            - VM_galera1.infra.opensuse.org
            - VM_galera2.infra.opensuse.org
            - VM_galera3.infra.opensuse.org
          sequential: true  # this only helps if it was shut down in the reverse order, but should not hurt in either case

        {%- elif group == 'postgresql' %}
            - VM_mirrordb2.infra.opensuse.org
            - VM_mirrordb1.infra.opensuse.org
          sequential: true

        {%- endif %}
    {%- endmacro %}

    {%- for vmpair in [
          'atlas',
          'hel',
        ]
    %}
    order_{{ vmpair }}:
      type: rsc_order
      kind: mandatory
      resources:
        - VM_{{ vmpair }}1.infra.opensuse.org
        - VM_{{ vmpair }}2.infra.opensuse.org
    {%- endfor %}

    order_dns_mysql:
      type: rsc_order
      kind: mandatory
      sets:
        {{ resource_set('dns') }}
        {{ resource_set('mysql') }}

    order_mysql_wiki:
      type: rsc_order
      kind: optional
      sets:
        {{ resource_set('mysql') }}
        - resources:
            - VM_riesling.infra.opensuse.org
            - VM_riesling3.infra.opensuse.org
          sequential: false

    order_postgresql_etherpad:
      type: rsc_order
      kind: mandatory
      sets:
        {{ resource_set('postgresql') }}
        - resources:
            - VM_etherpad.infra.opensuse.org

  fencing:
    stonith_enable: true
    sbd:
      devices:
        {#- /vol/lun_falkor_fencing1/sbd1001 #}
        - /dev/disk/by-id/dm-uuid-mpath-3600a09803831494c775d554b39507471
        {#- /vol/lun_falkor_fencing2/sbd1002 #}
        - /dev/disk/by-id/dm-uuid-mpath-3600a09803831494c775d554b39507472
        {#- /vol/lun_falkor_fencing3/sbd1003 #}
        - /dev/disk/by-id/dm-uuid-mpath-3600a09803831494f635d554b394f766e
      instances:
        {%- for i in [0, 1, 2] %}
        {%- set node = 'falkor' ~ i %}
        {{ node }}:
          pcmk_host_check: static-list
          pcmk_host_list: {{ node }}.infra.opensuse.org
        {%- endfor %}
  multicast:
    address: ff05:1002::f
  sysconfig:
    sbd:
      # FIXME - implement hardware watchdog
      SBD_WATCHDOG_DEV: /dev/watchdog
