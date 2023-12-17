prometheus:
  wanted:
    component:
      - prometheus
  pkg:
    component:
      prometheus:
        config:

          global:
            scrape_interval: 20s
            evaluation_interval: 30s
            external_labels:
              monitor: opensuse

          scrape_configs:

            # https://debuginfod.opensuse.org/metrics
            - job_name: debuginfod
              scheme: https
              static_configs:
                - targets:
                  - debuginfod.opensuse.org
                  labels:
                    alias: debuginfod

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
                regex: '(.*)\:9114'
                replacement: '$1'

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
                {%- for minion, fqdn in salt.saltutil.runner('mine.get', arg=['*', 'fqdn']).items() %}
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
