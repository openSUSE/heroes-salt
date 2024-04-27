include:
  - apache.config
  - prometheus.config
  - profile.monitoring.prometheus.alerts
  - profile.karma
  {%- if not grains['id'].startswith('runner-') %}
  - nfs.mount
  {%- endif %}
