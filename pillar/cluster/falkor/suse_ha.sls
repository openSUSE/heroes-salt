suse_ha:
  cluster:
    name: falkor
  fencing:
    stonith_enable: true
    sbd:
      devices:
        {#- /vol/lun_falkor_fencing1/sbd1001 #}
        - /dev/disk/by-id/dm-uuid-mpath-3600a09803831494f635d554b394f766c
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
