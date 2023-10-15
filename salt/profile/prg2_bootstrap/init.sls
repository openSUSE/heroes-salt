prg2_hosts:
  host.present:
    - names:
      - witch1.infra.opensuse.org:
        - ip: 2a07:de40:b27e:1200::a
      - download.infra.opensuse.org:
        - ip: 2a07:de40:b27e:1205::a
    - clean: true
