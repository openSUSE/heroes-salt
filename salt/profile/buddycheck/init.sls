{%- set buddycheck = salt['pillar.get']('profile:buddycheck', {}) %}
{%- set buddy      = buddycheck.get('buddy') %}
{%- set services   = buddycheck.get('services', []) %}
{%- set systemdir  = '/etc/systemd/system/' %}
{%- set dropin     = '.service.d/buddycheck.conf' %}

{%- if buddy and services %}

buddycheck_package:
  pkg.installed:
    - name: buddycheck

buddycheck_services:
  file.managed:
    - names:
        {%- for service in services %}
        - {{ systemdir }}{{ service }}{{ dropin }}
        {%- endfor %}
    - makedirs: True
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        - 'Environment=BUDDYCHECK_HOST={{ buddy }}'
        - 'ExecStartPre=/usr/bin/buddycheck'
    - require:
      - pkg: buddycheck_package

{%- else %}

buddycheck_package:
  pkg.removed:
    - name: buddycheck

{%- endif %} {#- close pillar check #}

{%- for path in salt['file.find'](systemdir, maxdepth=2, mindepth=2, name='buddycheck.conf', type='f') %}
  {%- set service = path.replace(systemdir, '').replace(dropin, '') %}
  {%- if not buddy or service not in services %}
buddycheck_disable_{{ service }}:
  file.absent:
    - name: {{ path }}
  {%- endif %}
{%- endfor %}
