{%- set sysconfig = '/etc/sysconfig/prometheus-node_exporter' -%}
{%- set server_address = salt['pillar.get']('profile:monitoring:nrpe:server_address', None) -%}
{%- if server_address is not none -%}
{%- set listen = server_address -%}
{%- elif pillar.get('sshd_config', {}).get('ListenAddress') is string -%}
{%- set listen = pillar['sshd_config']['ListenAddress'] -%}
{%- endif -%}

node_exporter_packages:
  pkg.installed:
    - pkgs:
      - golang-github-prometheus-node_exporter

node_exporter_sysconfig_header:
  file.prepend:
    - name: {{ sysconfig }}
    - text: {{ pillar['managed_by_salt'] | yaml_encode }}
    - require:
      - pkg: node_exporter_packages

node_exporter_sysconfig:
  file.replace:
    - name: {{ sysconfig }}
    - ignore_if_missing: {{ opts['test'] }}
    - pattern: |
        ^ARGS=.*$
    - repl: |
        ARGS="--web.listen-address={{ listen | ipwrap }}:9100 --collector.filesystem.fs-types-exclude='^(fuse.s3fs|fuse.cryfs|tmpfscgroup2?|debugfs|devpts|devtmpfs|fusectl|overlay|proc|procfs|pstore)\$' --no-collector.zfs --no-collector.thermal_zone --no-collector.powersupplyclass"
    - require:
      - pkg: node_exporter_packages
      - file: node_exporter_sysconfig_header

node_exporter_service:
  service.running:
    - name: prometheus-node_exporter
    - enable: True
    - require:
      - pkg: node_exporter_packages
      - file: node_exporter_sysconfig
    - watch:
      - file: node_exporter_sysconfig
