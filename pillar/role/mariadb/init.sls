{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.mariadb
{%- endif %}

nftables: true

os-update:
  ignore_services_from_restart:
    - mariadb

prometheus:
  wanted:
    component:
      - mysqld_exporter
  pkg:
    component:
      mysqld_exporter:
        environ:
          args:
            collect.binlog_size: true
            collect.engine_innodb_status: true
            collect.global_status: true
            collect.global_variables: true
            collect.info_schema.clientstats: true
            collect.info_schema.processlist: true
            collect.info_schema.query_response_time: true
            collect.info_schema.tables: true
            collect.info_schema.tablestats: true
            collect.info_schema.userstats: true
        name: golang-github-prometheus-mysqld_exporter
        service:
          name: prometheus-mysqld_exporter

sysctl:
  params:
    fs.aio-max-nr: 1048576
