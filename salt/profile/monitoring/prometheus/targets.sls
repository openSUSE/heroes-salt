include:
  - prometheus.service.running

{%- set monitors = salt['pillar.get']('profile:monitoring:prometheus:monitors', {}) -%}

{#- start collecting minions with a single mine call and pre-sort them into monitoring groups for
    later referencing as scrape targets
#}
{%- set targets = {} %}
{%- set mine = salt['mine.get'](tgt='*', fun=['grains', 'roles', 'states']) %}

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
    {%- do salt.log.warning('monitoring.prometheus.targets: unhandled virtual in mined minion ' ~ minion) %}
  {%- endif %}
{%- endfor %} {#- close grains loop #}

{#- gather role specific targets
    (based off the roles listed in the job configuration in the "monitors" block in the monitoring pillar)
#}
{%- for x in ['states', 'roles'] %}
  {%- for minion, roles in mine.get(x, {}).items() %}
    {%- if minion in targets %}
      {%- set minion_target = targets[minion] %}
      {%- for job, job_config in monitors.items() %}
        {%- if not 'targets' in monitors[job] %}
          {%- do monitors[job].update({'targets': []}) %}
        {%- endif %}
        {%- for role in job_config.get(x, []) %}
          {%- if role in roles and minion_target not in monitors[job]['targets'] %}
            {%- do monitors[job]['targets'].append(minion_target) %}
          {%- endif %}
        {%- endfor %}
      {%- endfor %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}

{%- do salt.log.debug('monitoring.prometheus.targets - targets: ' ~ targets) %}

{%- set targetsdir = '/etc/prometheus/targets' %}

{{ targetsdir }}:
  file.directory:
    - group: prometheus
    - require_in:
        - service: prometheus-service-running-prometheus

{{ targetsdir }}/__MANAGED_BY_SALT:
  file.managed:
    - contents:
        - Files in this directory are managed by Salt.
    - require:
        - file: {{ targetsdir }}

{%- for job, job_config in monitors.items() %}
{{ targetsdir }}/{{ job }}.json:
  file.serialize:
    - dataset:
        {%- if 'targets' in job_config %}
          {%- if job == 'nodes' %}
            {%- for virtual, fqdns in job_config['targets'].items() %}
        - labels:
            virtual: {{ virtual }}
          targets:
              {%- for fqdn in fqdns | sort %}
              - {{ fqdn }}:{{ job_config['port'] }}
              {%- endfor %}
            {%- endfor %}
          {%- else %}
        - targets:
              {%- for fqdn in job_config['targets'] | sort %}
              - {{ fqdn }}:{{ job_config['port'] }}
              {%- endfor %}
            {%- if job_config.get('tls') is sameas true %}
          labels:
            __scheme__: https
            {%- endif %}
          {%- endif %}
        {%- else %}
        - targets: []
        {%- endif %}
    - serializer: json
    - require:
        - file: {{ targetsdir }}
    - require_in:
        - service: prometheus-service-running-prometheus
{%- endfor %}

{%- for file in salt['file.find'](targetsdir, mindepth=1, print='name') %}
  {#- check file name minus possible .json suffix against managed jobs #}
  {%- if file != '__MANAGED_BY_SALT' and file[:-5] not in monitors %}
{{ targetsdir }}/{{ file }}:
  file.absent
  {%- endif %}
{%- endfor %}
