{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.pgbouncer
{%- endif %}

# pgBouncer is currently managed using static files in salt/profile/pgbouncer/files/<cluster>/

prometheus:
  wanted:
    component:
      - pgbouncer_exporter
  pkg:
    component:
      pgbouncer_exporter:
        # connection string is in pillar/secrets/role/pgbouncer.sls
        name: prometheus-pgbouncer_exporter
        service:
          name: prometheus-pgbouncer_exporter
