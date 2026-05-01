include:
  - apache_httpd
  - prometheus.config
  - profile.monitoring.prometheus.alerts
  - profile.monitoring.prometheus.targets
  - profile.karma
  {%- if not grains['id'].startswith('runner-') and not grains.get('CI_TEST_RUN') %}
  - nfs.mount
  {%- endif %}
