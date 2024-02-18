include:
  - role.common.monitoring
  - .alerts

prometheus:
  wanted:
    component:
      prometheus: {}

  pkg:
    component:
      prometheus:
        config:
          alerting:
            alertmanagers:
              - static_configs:
                  - targets:
                      - monitor.infra.opensuse.org:9093

          rule_files:
            - /etc/prometheus/rules/*.yml

          global:
            scrape_interval: 20s
            evaluation_interval: 30s
            external_labels:
              monitor: opensuse

          scrape_configs:

            - job_name: elasticsearch
              static_configs:
                - targets:
                    - water:9114
                    - water3:9114
                  labels:
                    service: elasticsearch
              relabel_configs:
                - source_labels:
                    - __address__
                  target_label: instance
                  regex: (.*)\:9114
                  replacement: $1

            - job_name: galera
              static_configs:
                # original configuration uses one target per host, which I don't understand (yet)
                #- targets: ['galera1:9104']
                #  labels:
                #    alias: galera1
                #- targets: ['galera2:9104']
                #  labels:
                #    alias: galera2
                #- targets: ['galera3:9104']
                #  labels:
                #    alias: galera3
                - targets:
                    {%- for i in [1, 2, 3] %}
                    - galera{{ i }}.infra.opensuse.org:9104
                    {%- endfor %}

            - job_name: mail
              scheme: http
              static_configs:
                - targets:
                    - mx-test.infra.opensuse.org:3903
              relabel_configs:
                - source_labels:
                    - __address__
                  target_label: instance
                  regex: ^([\w\.-]+)\:3903
                  replacement: $1

            - job_name: nodes
              static_configs:
                - targets:
                    {%- for minion, fqdn in salt.saltutil.runner('mine.get', arg=['*', 'fqdn']) | dictsort(by='value') %}
                    - {{ fqdn }}:9100
                    {%- endfor %}
              relabel_configs:
                - source_labels:
                    - __address__
                  target_label: instance
                  regex: ^([\w\.-]+)\:9100
                  replacement: $1

            - job_name: prometheus
              scrape_interval: 5s
              scrape_timeout: 5s
              static_configs:
                - targets:
                    - localhost:9090

            - job_name: salt
              scrape_interval: 15s
              scrape_timeout: 5s
              static_configs:
                - targets:
                    - witch1.infra.opensuse.org:8216
                  labels:
                    __scheme__: https
              relabel_configs:
                - regex: ^([\w\.]+)\:8216
                  replacement: $1
                  source_labels:
                    - __address__
                  target_label: instance

            {%- set mioo = 'matrix.infra.opensuse.org' %}
            - job_name: synapse
              metrics_path: /_synapse/metrics
              scrape_interval: 15s
              static_configs:
                # main process
                - targets:
                    - {{ mioo }}:8009
                  labels:
                    instance: {{ mioo }}
                    job: synapse_master
                    index: 1
                # workers (as defined in pillar/role/matrix.sls)
                - targets:
                    - {{ mioo }}:18501
                  labels:
                    instance: {{ mioo }}
                    job: synapse_sync
                    index: 1
                - targets:
                    - {{ mioo }}:18511
                  labels:
                    instance: {{ mioo }}
                    job: synapse_federation_request
                    index: 1
                - targets:
                    - {{ mioo }}:18512
                  labels:
                    instance: {{ mioo }}
                    job: synapse_federation_request
                    index: 2
                - targets:
                    - {{ mioo }}:18521
                  labels:
                    instance: {{ mioo }}
                    job: synapse_client
                    index: 1
                - targets:
                    - {{ mioo }}:18522
                  labels:
                    instance: {{ mioo }}
                    job: synapse_client
                    index: 2
                - targets:
                    - {{ mioo }}:18531
                  labels:
                    instance: {{ mioo }}
                    job: synapse_login
                    index: 1
                - targets:
                    - {{ mioo }}:18541
                  labels:
                    instance: {{ mioo }}
                    job: synapse_event
                    index: 1
                - targets:
                    - {{ mioo }}:18542
                  labels:
                    instance: {{ mioo }}
                    job: synapse_event
                    index: 2
                - targets:
                    - {{ mioo }}:18551
                  labels:
                    instance: {{ mioo }}
                    job: synapse_pusher
                    index: 1
                - targets:
                    - {{ mioo }}:18552
                  labels:
                    instance: {{ mioo }}
                    job: synapse_pusher
                    index: 2
                - targets:
                    - {{ mioo }}:18571
                  labels:
                    instance: {{ mioo }}
                    job: synapse_federation_sender
                    index: 1
                - targets:
                    - {{ mioo }}:18572
                  labels:
                    instance: {{ mioo }}
                    job: synapse_federation_sender
                    index: 2
                - targets:
                    - {{ mioo }}:18601
                  labels:
                    instance: {{ mioo }}
                    job: synapse_frontend_proxy
                    index: 1
                - targets:
                    - {{ mioo }}:18591
                  labels:
                    instance: {{ mioo }}
                    job: synapse_room_keys
                    index: 1

        environ:
          environ_arg_name: ARGS  # SUSE package specific
          args:
            web.external-url: http://monitor.infra.opensuse.org:9090

