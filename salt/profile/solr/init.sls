solr_package:
  pkg.installed:
    - name: solr

solr_default_header:
  file.prepend:
    - name: /etc/default/solr.in.sh
    - text: {{ pillar['managed_by_salt'] | yaml_encode }}
    - require:
        - pkg: solr_package

solr_default:
  file.keyvalue:
    - name: /etc/default/solr.in.sh
    - key_values:
        SOLR_REQUESTLOG_ENABLED: 'false'
        SOLR_IP_ALLOWLIST: '"[::1]"'
        SOLR_JETTY_HOST: '"::1"'
        SOLR_MODULES: '"scripting"'
    - ignore_if_missing: {{ opts['test'] }}
    - uncomment: '#'
    - require:
        - pkg: solr_package

solr_service:
  service.running:
    - name: solr
    - enable: true
    - require:
        - pkg: solr_package
    - watch:
        - file: solr_default
