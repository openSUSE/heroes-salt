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
            - job_name: prometheus
              scrape_interval: 5s
              scrape_timeout: 5s
              static_configs:
              - targets:
                - localhost:9090

            - job_name: monitor
              static_configs:
              - targets:
                - localhost:9100

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
                regex: '(.*)\:9114'
                target_label: instance
                replacement: '$1'

            # https://debuginfod.opensuse.org/metrics
            - job_name: debuginfod
              scheme: https
              static_configs:
                - targets:
                  - debuginfod.opensuse.org
                  labels:
                    alias: debuginfod
