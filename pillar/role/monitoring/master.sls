{%- set listen = grains['fqdn_ip6'][0] %}

include:
  - role.common.apache
  - role.common.monitoring
  - .alerts

apache:
  sites:
    http:
      interface: '{{ listen | ipwrap }}'
      Rewrite: |
        RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
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
      interface: '{{ listen | ipwrap }}'
      port: 443
      SSLCertificateFile: /etc/ssl/services/monitor.infra.opensuse.org/fullchain.pem
      SSLCertificateKeyFile: /etc/ssl/services/monitor.infra.opensuse.org/privkey.pem
      Protocols:
        - h2
        - http/1.1
      ServerName: {{ vhost }}.infra.opensuse.org
      {%- if 'alias' in vconfig %}
      ServerAlias: {{ vconfig['alias'] }}.infra.opensuse.org
      {%- endif %}
      ProxyRoute:
        - ProxyPassSource: /
          ProxyPassTarget: http://ipv6-localhost:{{ vconfig['port'] }}/
    {%- endfor %}
    monitor:
      interface: '{{ listen | ipwrap }}'
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
      Include: /etc/apache2/conf.d/icingaweb2.conf

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

            {#- start collecting minions with a single mine call and pre-sort them into monitoring groups for
                later referencing as scrape targets
            #}
            {%- set targets = {
                      'all': {},
                      'nodes': {
                        'physical': [], 'kvm': []
                      },
                      'elasticsearch': [],
                      'mysql': [],
                      'salt': [],
                    }
            %}
            {%- set mine = salt.saltutil.runner('mine.get', tgt='*', fun=['grains', 'roles']) %}

            {%- for minion, mined_grains in mine.get('grains', {}).items() %}
              {#- check if the virtual grain is known (there should not be any minions with "stray" virtual values around) #}
              {%- if mined_grains['virtual'] in targets['nodes'] %}
                {#- store FQDN in the virtual specific list #}
                {%- do targets['nodes'][mined_grains['virtual']].append(mined_grains['fqdn']) %}
                {#- store minion->FQDN map for referencing the FQDN in the role iterations, which would otherwise
                    only have access to the minion ID which is served as the key of any mine query
                    (although in theory, the IDs of our minions should always match their FQDN)
                #}
                {%- do targets['all'].update({minion: mined_grains['fqdn']}) %}
              {%- else %}
                {%- do salt.log.warning('monitoring.master: unhandled virtual in mined minion ' ~ minion) %}
              {%- endif %}
            {%- endfor %} {#- close grains loop #}

            {#- collect role specific target groups
                this allows for automatic enrollment of nodes running services covered by our monitoring
                (i.e. services we deploy exporters for) to the respective service specific metric collections
            #}
            {%- for minion, roles in mine.get('roles', {}).items() %}
              {%- if minion in targets['all'] %}

                {#- MySQL (mysqld-exporter) #}
                {%- if 'mariadb' in roles %}
                  {%- do targets['mysql'].append(targets['all'][minion]) %}
                {%- endif %}

                {#- Salt (saline) #}
                {%- if 'saltmaster' in roles %}
                  {%- do targets['salt'].append(targets['all'][minion]) %}
                {%- endif %}

                {#- Elasticsearch (elasticsearch-exporter) #}
                {%- if 'wikisearch' in roles %}
                  {%- do targets['elasticsearch'].append(targets['all'][minion]) %}
                {%- endif %}

              {%- endif %} {#- close minion in targets check #}
            {%- endfor %} {#- close roles loop #}

            - job_name: elasticsearch
              static_configs:
                - targets:
                    {%- for fqdn in targets['elasticsearch'] | sort %}
                    - {{ fqdn }}:9114
                    {%- endfor %}
                  labels:
                    service: elasticsearch
              relabel_configs:
                - source_labels:
                    - __address__
                  target_label: instance
                  regex: ^(\w+)\.infra\.opensuse\.org\:9114
                  replacement: $1

            - job_name: galera
              static_configs:
                - targets:
                    {%- for fqdn in targets['mysql'] | sort  %}
                    - {{ fqdn }}:9104
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
                {%- for virtual, fqdns in targets['nodes'].items() %}
                - labels:
                    virtual: {{ virtual }}
                  targets:
                    {%- for fqdn in fqdns | sort %}
                    - {{ fqdn }}:9100
                    {%- endfor %}
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
                    {%- for fqdn in targets['salt'] | sort  %}
                    - {{ fqdn }}:8216
                    {%- endfor %}
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
        - proxy_url: string
          source: http://localhost:9090
          uri: http://monitor.infra.opensuse.org:9090
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
        # opensuse-mail merely "duplicates" critical alerts already sent to opensuse-irc - avoid duplication in the UI
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
