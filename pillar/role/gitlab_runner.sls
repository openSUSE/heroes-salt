include:
  - .docker
  # secrets include conditionalized inside the secrets files
  - secrets.id.{{ grains['id'].replace('.', '_') }}

profile:
  docker:
    daemon:
      ipv6: true
      fixed-cidr-v6: 2a07:de40:b27e:400{{ grains['host'][-1] }}::/64
  gitlab_runner:
    config:
      concurrent: 30
      check_interval: 5
      user: gitlab-runner
      shutdown_timeout: 0
      session_server:
        session_timeout: 1800
    # further runner configuration is in pillar/role/common/gitlab_runner/macros.jinja
    # included together with secrets in pillar/secrets/id/gitlab-runner*

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

zypper:
  packages:
    # needed by Salt for TOML configuration serialization
    # move to the common pillar should we get more roles needing TOML
    python3-toml: {}
