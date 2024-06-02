include:
  - role.common.wiki

apparmor:
  profiles:
    elasticsearch:
      source: salt://profile/wikisearch/files/elasticsearch.apparmor

elasticsearch:
  pkg: elasticsearch6
  use_repo: False
  config:
    node.name: ${HOSTNAME}
    node.master: true
    node.data: true
    path.data: /var/lib/elasticsearch
    path.logs: /var/log/elasticsearch
    network.host: 0.0.0.0
    http.port: 9200
    http.enabled: true
  sysconfig:
    # elasticsearch-formula rewrites the sysconfig file from scratch, therefore we have to copy all of its contents here
    ES_PATH_CONF: /etc/elasticsearch
    ES_STARTUP_SLEEP_TIME: 5
  version: 6.8.23

prometheus:
  wanted:
    component:
      - elasticsearch_exporter
  pkg:
    component:
      elasticsearch_exporter:
        name: prometheus-elasticsearch_exporter
        service:
          name: prometheus-elasticsearch_exporter

sysctl:
  params:
    vm.max_map_count: 262144
