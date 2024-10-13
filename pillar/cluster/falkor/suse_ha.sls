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
