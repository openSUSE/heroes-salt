include:
  - apache_httpd
  - prometheus.config
  - profile.monitoring.prometheus.alerts
  - profile.monitoring.prometheus.targets
  - profile.karma
  {%- if not grains['id'].startswith('runner-') %}
  - nfs.mount
  {%- endif %}
