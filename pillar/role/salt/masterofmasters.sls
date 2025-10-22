infrastructure:
  salt:
    master:
      gpg: False

salt:
  master:
    order_masters: True
    syndic_wait: 2
    nodegroups:
      firewalls: N@asgard and N@avalon
      internal-rproxies: N@hel and N@tyr
      public-rproxies: N@atlas and N@globus
      dns: N@prg-ns and N@slc-ns
      warp: warp.infra.opensuse.org and N@slc-warp
      mail: N@mail-prg and mx-test.infra.opensuse.org
      syndics: {{ grains.get('partners', []) }}
