suse_ha:
  cluster:
    name: arches
  constraints:
    {%- for vmpair in [
          'globus',
        ]
    %}
    colo_{{ vmpair }}:
      type: rsc_colocation
      score: -100
      resources:
        - VM_{{ vmpair }}1.infra.opensuse.org
        - VM_{{ vmpair }}2.infra.opensuse.org
    {%- endfor %}
  fencing:
    stonith_enable: true
    sbd:
      devices:
        {#- /vol/lun_arches2_fencing1/sbd1001 #}
        - /dev/disk/by-id/dm-uuid-mpath-3600a0980383143393724584a74517674
        {#- /vol/lun_arches2_fencing2/sbd1002 #}
        - /dev/disk/by-id/dm-uuid-mpath-3600a0980383143393724584a74517675
        {#- /vol/lun_arches2_fencing3/sbd1003 #}
        - /dev/disk/by-id/dm-uuid-mpath-3600a0980383143393724584a74517676
      instances:
        {%- for i in [0, 1, 2] %}
        {%- set node = 'arches' ~ i %}
        {{ node }}:
          pcmk_host_check: static-list
          pcmk_host_list: {{ node }}.infra.opensuse.org
        {%- endfor %}
  multicast:
    address: ff05:1701::a
  sysconfig:
    sbd:
      SBD_WATCHDOG_DEV: /dev/watchdog
