{%- set listen = grains['fqdn_ip6'][0] %}

{%- macro relabel_instance(port) %}
              relabel_configs:
                - source_labels:
                    - __address__
                  target_label: instance
                  regex: ^([\w\.-]+)\:{{ port }}
                  replacement: $1
{%- endmacro %}
{%- macro vhost_defaults(name) %}
      listen: '{{ listen | ipwrap }}:443'
      SSLCertificateFile: /etc/ssl/services/monitor.infra.opensuse.org/fullchain.pem
      SSLCertificateKeyFile: /etc/ssl/services/monitor.infra.opensuse.org/privkey.pem
      Protocols:
        - h2
        - http/1.1
      ServerName: {{ name }}.infra.opensuse.org
{%- endmacro %}

include:
  - role.common.apache
  - role.common.backup
  - role.common.monitoring

apache_httpd:
  modules:
    - proxy
    - proxy_http
  vhosts:
    http:
      listen: '{{ listen | ipwrap }}:80'
      RewriteRule:
        - ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
    {%- for vhost, vconfig in {
          'karma': {
            'port': 9193,
            'alias': 'alerts',
          },
          'prometheus': {
            'port': 9090,
          },
          'alertmanager': {
            'port': 9093,
          },
        }.items()
    %}
    {{ vhost }}:
      {{ vhost_defaults(vhost) }}
      {%- if 'alias' in vconfig %}
      ServerAlias: {{ vconfig['alias'] }}.infra.opensuse.org
      {%- endif %}
      ProxyPass:
        /: http://ipv6-localhost:{{ vconfig['port'] }}/
      {%- if vhost == 'prometheus' %}
      Location:
        /api/v1/admin:
          Require: all denied
      {%- endif %}
    {%- endfor %}
    monitor:
      listen: '{{ listen | ipwrap }}:80'
      CustomLog:
        env: =!donotlog
      ServerName: monitor.opensuse.org
      DocumentRoot: /srv/www/htdocs
      Alias:
        /heroes: /home/supybot/supybot/logs/ChannelLogger/libera/#opensuse-admin
        /opensuse-admin: /home/supybot/supybot/logs/ChannelLogger/libera/#opensuse-admin
      Directory:
        /srv/www/htdocs:
          Require: all granted
        /home/supybot/supybot/logs/ChannelLogger/libera/#opensuse-admin:
          AddType: text/plain .log
          IndexOrderDefault: Descending Name
          Options: Indexes
          Require: all granted
    monitor-internal:
      {{ vhost_defaults('monitor') }}
      DocumentRoot: /srv/www/monitor-internal
      Directory:
        /srv/www/monitor-internal:
          Options: indexes
          Require: all granted

prometheus:
  wanted:
    component:
      - prometheus

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

            {#-
              <job name>:
                port: <integer - port the exporter is listening on>
                roles: [<list - Salt roles the minions in which to target>]
                states: [<list - Salt states of which the minions including them to target>]
                simple: <boolean - true for simple exporters exposing /metrics and not requiring special settings, false (default) for ones with custom scrape_config blocks>
                targets: [<empty list - automatically populated>]
            #}
            {%- load_yaml as monitors %}

            nodes:
              port: 9100
              simple: true
              # target lists are pre-initialized in the "nodes" job to define the acceptable "virtual" grains
              # minions with other "virtual" values will not be covered by this job
              targets:
                physical: []
                kvm: []

            apache:
              port: 9117
              roles: []
              states:
                - apache_httpd
              simple: true

            discourse:
              port: 9405
              roles:
                - discourse
              simple: true

            elasticsearch:
              port: 9114
              roles:
                - wikisearch
              simple: true

            ha_cluster:
              port: 9664
              roles:
                - hypervisor.cluster
              scrape:
                interval: 5m
                timeout: 1m
              simple: true

            haproxy:
              port: 8404
              roles:
                - proxy
              simple: true

            mail:
              port: 3903
              roles:
                - mailman3
                - mailserver
              simple: true

            mysql:
              port: 9104
              roles:
                - mariadb
                - mariadb.backup
              simple: true

            nginx:
              port: 9113
              roles: []
              states:
                - nginx.config
              simple: true

            pgbouncer:
              port: 9127
              roles:
                - pgbouncer
              simple: true

            php-fpm:
              port: 9253
              roles:
                - limesurvey
                - wiki
              simple: true

            ping:
              port: 9427
              roles:
                - gateway
              simple: true

            postgresql:
              port: 9187
              roles:
                - postgresql
                - postgresql.backup
              simple: true

            salt:
              port: 8216
              roles:
                - salt.master
              scrape:
                interval: 15s
                timeout: 5s
              simple: true
              tls: true

            smartctl:
              port: 9633
              states:
                - smartmontools.smartd
              scrape:
                interval: 5m
              simple: true

            solr:
              port: 8989
              roles:
                - mailman3
              scrape:
                interval: 2m
                timeout: 10s
              simple: true
              path: /

            {%- endload %}

            {#- simple jobs using the default settings and SD targets: #}

            {%- for job, job_config in monitors.items() %}
            {%- if job_config.get('simple', False) and 'port' in job_config %}
            - job_name: {{ job }}
              {%- if 'path' in job_config %}
              metrics_path: {{ job_config['path'] }}
              {%- endif %}
              {%- if 'scrape' in job_config %}
                {%- if 'interval' in job_config['scrape'] %}
              scrape_interval: {{ job_config['scrape']['interval'] }}
                {%- endif %}
                {%- if 'timeout' in job_config['scrape'] %}
              scrape_timeout: {{ job_config['scrape']['timeout'] }}
                {%- endif %}
              {%- endif %}
              file_sd_configs:
                - files:
                    - /etc/prometheus/targets/{{ job }}.json
              {{ relabel_instance(job_config['port']) }}
            {%- endif %}
            {%- endfor %}

            {#- jobs with static targets: #}

            - job_name: prometheus
              scrape_interval: 5s
              scrape_timeout: 5s
              static_configs:
                - targets:
                    - localhost:9090

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
                - targets:
                    - {{ mioo }}:18581
                  labels:
                    instance: {{ mioo }}
                    job: synapse_media_repository
                    index: 1
                - targets:
                    - {{ mioo }}:18582
                  labels:
                    instance: {{ mioo }}
                    job: synapse_media_repository
                    index: 2

        environ:
          environ_arg_name: ARGS  # SUSE package specific
          args:
            storage.tsdb.path: /data/prometheus/metrics
            storage.tsdb.retention.time: 1y
            web.enable-admin-api: true
            web.external-url: https://prometheus.infra.opensuse.org
            web.listen-address: '[::1]:9090'

profile:
  karma:
    alertmanager:
      interval: 15s
      servers:
        - name: local
          healthcheck:
            filters:
              prometheus:
                - alertname=PrometheusDeadManSwitch
          proxy: true
          readonly: false
          timeout: 10s
          uri: http://ipv6-localhost:9093
    annotations:
      hidden:
        - description
      order:
        - title
        - summary
        - description
    filters:
      default:
        - '@state!=suppressed'
    grid:
      sorting:
        order: label
        label: instance
    history:
      enabled: true
      rewrite:
        - source: https://prometheus.infra.opensuse.org
          uri: http://ipv6-localhost:9090
      timeout: 10s
      workers: 4
    karma:
      name: karma-heroes
    labels:
      color:
        custom:
          severity:
            - color: '#87c4e0'
              value: info
            - color: '#ffae42'
              value: warning
            - color: '#ff220c'
              value: critical
        static:
          - job
        unique:
          - cluster
          - instance
      strip:
        - monitor
        - receiver
    listen:
      address: '[::1]'
      cors:
        allowedOrigins:
          - http://monitor.infra.opensuse.org
      port: 9193
      prefix: /
    log:
      config: false
      level: info
    receivers:
      strip:
        # these routes merely "duplicate" critical alerts already sent to opensuse-irc - avoid duplication in the UI
        - opensuse-action
        - opensuse-mail
    silenceForm:
      defaultAlertmanagers:
        - local
      strip:
        labels:
          - job
    silences:
      comments:
        linkDetect:
          rules:
            - regex: (poo#[0-9]+)
              uriTemplate: https://progress.opensuse.org/issues/$1
    ui:
      colorTitlebar: true
      minimalGroupWidth: 600

  monitoring:
    prometheus:
      monitors: {{ monitors | yaml }}

nftables: true
