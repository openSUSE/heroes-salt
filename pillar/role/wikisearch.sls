apparmor:
  profiles:
    elasticsearch:
      source: salt://profile/wikisearch/files/elasticsearch.apparmor

elasticsearch:
  add_repo: False
  config:
    node.name: ${HOSTNAME}
    node.master: true
    node.data: true
    index.number_of_shards: 1
    index.number_of_replicas: 0
    network.host: 0.0.0.0
    http.port: 9200
    http.enabled: true
    discovery.zen.minimum_master_nodes: 1
    discovery.zen.ping.multicast.enabled: false
  sysconfig:
    # elasticsearch-formula rewrites the sysconfig file from scratch, therefore we have to copy all of its contents here
    CONF_DIR: /etc/elasticsearch
    CONF_FILE: /etc/elasticsearch/elasticsearch.yml
    DATA_DIR: /var/lib
    ES_CLUSTER_NAME: elasticsearch
    ES_DIRECT_SIZE: ''
    ES_HEAP_NEWSIZE: ''
    ES_HEAP_SIZE: 256m
    ES_HOME: /usr/share/elasticsearch
    ES_HTTP_HOST: ''
    ES_JAVA_OPTS: ''
    ES_NODE_NAME: ''
    ES_PLUGIN_DIR: /usr/share/java/elasticsearch/plugins
    ES_STARTUP_SLEEP_TIME: 5
    ES_USER: elasticsearch
    LOG_DIR: /var/log/elasticsearch
    MAX_OPEN_FILES: 65534
    MAX_LOCKED_MEMORY: unlimited
    PID_DIR: /var/run/elasticsearch
    RESTART_ON_UPGRADE: true
    WORK_DIR: /tmp/elasticsearch
  version: 1.7.6

sudoers:
  included_files:
    /etc/sudoers.d/group_wiki-admins:
      groups:
        wiki-admins:
          - 'ALL=(ALL) ALL'

zypper:
  repositories:
    openSUSE:infrastructure:wiki:
      baseurl: http://download.opensuse.org/repositories/openSUSE:/infrastructure:/wiki/openSUSE_Leap_{{ grains['osrelease'] }}
      gpgcheck: 0
      priority: 100
      refresh: True
