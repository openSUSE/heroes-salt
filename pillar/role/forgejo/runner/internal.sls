{%- set site = grains.get('site') %}

include:
  - .

apparmor:
  local:
    # for test_syslog-ng (no better way to allow this only inside the container?)
    sbin.syslog-ng:
      - /etc/syslog-ng/conf.d/server.d/{,*} r

profile:
  forgejo:
    runner:
      config:
        server:
          connections:
            forgejo-internal:
              url: https://git.infra.opensuse.org
      {%- if site %}
      podman:
        subnet: >-
          {%- if site == 'prg2' %}
          2a07:de40:b27e:400::/64
          {%- elif site == 'slc1' %}
          2a07:de40:617e:400::/64
          {%- endif %}
      {%- endif %}

prometheus:
  pkg:
    component:
      node_exporter:
        environ:
          args:
            # is a bind mount, metrics from /data apply, exclude to avoid duplicates
            # consider removing the exclude after a solution for https://github.com/prometheus/node_exporter/issues/600
            collector.filesystem.mount-points-exclude: "'^/var/lib/containers$'"

sysctl:
  params:
    vm.swappiness: 5
