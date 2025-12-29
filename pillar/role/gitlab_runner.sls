{%- set siteconfig = {
      'prg2': {
        'check_interval': 5,
        'concurrent': 30,
        'subnet_stub': '2a07:de40:b27e:400',
      },
      'slc1': {
        'check_interval': 30,
        'concurrent': 40,
        'subnet_stub': '2a07:de40:617e:400',
      },
} %}
{%- set config = siteconfig.get(grains.get('site')) %}
{%- if not config %}
  {%- do salt.log.warning('gitlab_runner: unknown site, pillar might be incomplete') %}
{%- endif %}

include:
  - secrets.include_id

apparmor:
  local:
    # for test_syslog-ng
    sbin.syslog-ng:
      - /etc/syslog-ng/conf.d/server.d/{,*} r

profile:
  gitlab_runner:
    config:
      user: gitlab-runner
      shutdown_timeout: 0
      session_server:
        session_timeout: 1800
    # further runner configuration is in pillar/role/common/gitlab_runner/macros.jinja
    # included together with secrets in pillar/secrets/id/gitlab-runner*
    {%- if config %}
      check_interval: {{ config['check_interval'] }}
      concurrent: {{ config['concurrent'] }}
    podman:
      subnet: {{ config['subnet_stub'] }}{{ grains['host'][-1] }}::/64
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

zypper:
  packages:
    # needed by Salt for TOML configuration serialization
    # move to the common pillar should we get more roles needing TOML
    {{ grains['system_python'] }}-toml: {}
  repositories:
    darix:apps:
      baseurl: http://$mirror_int/repositories/home:/darix:/apps/$releasever/
      priority: 100
      refresh: True
