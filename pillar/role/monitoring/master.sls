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
              targets:
                physical: []
                kvm: []

            apache:
              port: 9117
              roles: []
              states:
                - apache_httpd
              simple: true
              targets: []

            discourse:
              port: 9405
              roles:
                - discourse
              simple: true
              targets: []

            elasticsearch:
              port: 9114
              roles:
                - wikisearch
              simple: true
              targets: []

            ha_cluster:
              port: 9664
              roles:
                - hypervisor.cluster
              scrape:
                interval: 5m
                timeout: 1m
              simple: true
              targets: []

            haproxy:
              port: 8404
              roles:
                - proxy
              simple: true
              targets: []

            mail:
              port: 3903
              roles:
                - mailman3
                - mailserver
              simple: true
              targets: []

            mysql:
              port: 9104
              roles:
                - mariadb
                - mariadb.backup
              simple: true
              targets: []

            nginx:
              port: 9113
              roles: []
              states:
                - nginx.config
              simple: true
              targets: []

            pgbouncer:
              port: 9127
              roles:
                - pgbouncer
              simple: true
              targets: []

            ping:
              port: 9427
              roles:
                - gateway
              simple: true
              targets: []

            postgresql:
              port: 9187
              roles:
                - postgresql
                - postgresql.backup
              simple: true
              targets: []

            salt:
              port: 8216
              roles:
                - saltmaster
              targets: []

            smartctl:
              port: 9633
              states:
                - smartmontools.smartd
              scrape:
                interval: 5m
              simple: true
              targets: []

            solr:
              port: 8989
              roles:
                - mailman3
              targets: []

            {%- endload %}

            {#- start collecting minions with a single mine call and pre-sort them into monitoring groups for
                later referencing as scrape targets
            #}
            {%- set targets = {} %}
            {%- set mine = salt.saltutil.runner('mine.get', tgt='*', fun=['grains', 'roles', 'states']) %}

            {#- gather targets for the "nodes" job, i.e. node exporters running on all minions #}
            {%- for minion, mined_grains in mine.get('grains', {}).items() %}
              {#- check if the virtual grain is known (there should not be any minions with "stray" "virtual" values around) #}
              {%- if mined_grains['virtual'] in monitors['nodes']['targets'] %}
                {#- store FQDN in the virtual specific list #}
                {%- do monitors['nodes']['targets'][mined_grains['virtual']].append(mined_grains['fqdn']) %}
                {#- store minion->FQDN map for referencing the FQDN in the role iterations, which would otherwise
                    only have access to the minion ID which is served as the key of any mine query
                    (although in theory, the IDs of our minions should always match their FQDN)
                #}
                {%- do targets.update({minion: mined_grains['fqdn']}) %}
              {%- else %}
                {%- do salt.log.warning('monitoring.master: unhandled virtual in mined minion ' ~ minion) %}
              {%- endif %}
            {%- endfor %} {#- close grains loop #}

            {#- gather role specific targets
                (based off the roles listed in the job configuration in the "monitors" YAML block)
            #}
            {%- for x in ['states', 'roles'] %}
            {%- for minion, roles in mine.get(x, {}).items() %}
              {%- if minion in targets %}
                {%- set minion_target = targets[minion] %}
                {%- for job, job_config in monitors.items() %}
                  {%- for role in job_config.get(x, []) %}
                    {%- if role in roles and minion_target not in monitors[job]['targets'] %}
                      {%- do monitors[job]['targets'].append(minion_target) %}
                    {%- endif %}
                  {%- endfor %}
                {%- endfor %}
              {%- endif %}
            {%- endfor %}
            {%- endfor %}

            {%- do salt.log.debug('role.monitoring.master - targets: ' ~ targets) %}

            {#- simple jobs using the default settings: #}

            {%- for job, job_config in monitors.items() %}
            {%- if job_config.get('simple', False) and 'port' in job_config %}
            {%- set port = job_config['port'] %}
            - job_name: {{ job }}
              {%- if 'scrape' in job_config %}
                {%- if 'interval' in job_config['scrape'] %}
              scrape_interval: {{ job_config['scrape']['interval'] }}
                {%- endif %}
                {%- if 'timeout' in job_config['scrape'] %}
              scrape_timeout: {{ job_config['scrape']['timeout'] }}
                {%- endif %}
              {%- endif %}
              static_configs:
                - targets:
                    {%- for fqdn in job_config['targets'] | sort %}
                    - {{ fqdn }}:{{ port }}
                    {%- endfor %}
              {{ relabel_instance(port) }}
            {%- endif %}
            {%- endfor %}

            {#- jobs with custom settings: #}

            - job_name: nodes
              static_configs:
                {%- for virtual, fqdns in monitors['nodes']['targets'].items() %}
                - labels:
                    virtual: {{ virtual }}
                  targets:
                    {%- for fqdn in fqdns | sort %}
                    - {{ fqdn }}:{{ monitors['nodes']['port'] }}
                    {%- endfor %}
                {%- endfor %}
              {{ relabel_instance(monitors['nodes']['port']) }}

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
                    {%- for fqdn in monitors['salt']['targets'] | sort  %}
                    - {{ fqdn }}:{{ monitors['salt']['port'] }}
                    {%- endfor %}
                  labels:
                    __scheme__: https
              {{ relabel_instance(monitors['salt']['port']) }}

            - job_name: solr
              metrics_path: /
              scrape_interval: 2m
              scrape_timeout: 10s
              static_configs:
                - targets:
                    {%- for fqdn in monitors['solr']['targets'] %}
                    - {{ fqdn }}:{{ monitors['solr']['port'] }}
                    {%- endfor %}
              {{ relabel_instance(monitors['solr']['port']) }}

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

nftables: true
