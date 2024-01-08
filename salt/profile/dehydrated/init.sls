{%- set mypillar = salt['pillar.get']('profile:dehydrated', {}) %}

profile_dehydrated_packages:
  pkg.installed:
    - names:
      - dehydrated
      - python3-dns-lexicon

{%- for instance, instance_config in mypillar.get('instances', {}).items() %}
{%- set topdir = '/etc/dehydrated-' ~ instance ~ '/' %}

profile_dehydrated_{{ instance }}_top_directories:
  file.directory:
    - names:
      - {{ topdir }}
      - /var/log/dehydrated-{{ instance }}
    - group: dehydrated
    - mode: '0750'
    - require:
      - pkg: profile_dehydrated_packages

profile_dehydrated_{{ instance }}_sub_directories:
  file.directory:
    - names:
      {%- for dir in ['accounts', 'archive', 'certs'] %}
      - {{ topdir }}{{ dir }}:
        - user: dehydrated
        - mode: '0700'
      {%- endfor %}
      {%- for dir in ['config.d', 'hook.d'] %}
      - {{ topdir }}{{ dir }}:
        - mode: '0750'
      {%- endfor %}
      - /var/log/dehydrated-{{ instance }}/deployment_failures:
        - mode: '0755'
    - group: dehydrated
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_top_directories

profile_dehydrated_{{ instance }}_config_base:
  file.managed:
    - name: {{ topdir }}config
    - group: dehydrated
    - mode: '0640'
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - 'DEHYDRATED_USER="dehydrated"'
        - 'DEHYDRATED_GROUP="dehydrated"'
        - 'BASEDIR={{ topdir }}'
        - 'CONFIG_D="${BASEDIR}/config.d"'
        - 'WELLKNOWN=/var/lib/acme-challenge'
        - 'LOCKFILE="/run/dehydrated/lock-{{ instance }}"'
        - 'HOOK="${BASEDIR}/hook.sh"'
        - 'DOMAINS_TXT="${BASEDIR}/salt-domains.txt"'
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories

profile_dehydrated_{{ instance }}_config_custom:
  file.managed:
    - name: {{ topdir }}config.d/salt.sh
    - group: dehydrated
    - mode: '0640'
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        {%- for key, value in mypillar.get('config', {}).items() %}
        {% if value is sameas true %}
        {%- set value = 'yes' %}
        {%- elif value is sameas false %}
        {%- set value = 'no' %}
        {%- endif %}
        - '{{ key | upper }}="{{ value }}"'
        {%- endfor %}
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories

profile_dehydrated_{{ instance }}_config_domains:
  file.managed:
    - name: {{ topdir }}salt-domains.txt
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '# pillar/infra/certificates/{{ instance }}.yaml'
        {%- for certificate, certificate_config in instance_config.get('certificates', {}).items() %}
        - '{{ certificate }} {{ ' '.join(certificate_config.get('sans', [])) }} '
        {%- endfor %}
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories

profile_dehydrated_{{ instance }}_hook:
  file.managed:
    - name: {{ topdir }}hook.sh
    - source: salt://profile/dehydrated/files/etc/dehydrated/hook.sh.jinja
    - context:
        instance: {{ instance }}
    - template: jinja
    - group: dehydrated
    - mode: '0750'
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories
      - file: profile_dehydrated_{{ instance }}_config_domains

{%- for certificate, certificate_config in instance_config.get('certificates', {}).items() %}
{%- do salt.log.debug('dehydrated: parsing certificate ' ~ certificate) %}
{%- set targets = certificate_config.get('targets') %}
{%- if targets %}
profile_dehydrated_{{ instance }}_hook_{{ certificate }}:
  file.managed:
    - name: {{ topdir }}hook.d/{{ certificate }}.sh
    - source: salt://profile/dehydrated/files/etc/dehydrated/hook.d/certificate.sh.jinja
    - template: jinja
    - context:
        instance: {{ instance }}
        certificate: {{ certificate }}
        targets: {{ targets }}
    - group: dehydrated
    - mode: '0750'
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories
{%- endif %}
{%- endfor %}

profile_dehydrated_{{ instance }}_timer:
  service.running:
    - name: dehydrated@{{ instance }}.timer
    - enable: true
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories
      - file: profile_dehydrated_{{ instance }}_config_base
      - file: profile_dehydrated_{{ instance }}_config_custom
      - file: profile_dehydrated_{{ instance }}_hook

profile_dehydrated_{{ instance }}_service:
  service.running:
    - name: dehydrated@{{ instance }}.service
    - onchanges:
      - file: profile_dehydrated_{{ instance }}_config_domains
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories
      - file: profile_dehydrated_{{ instance }}_config_base
      - file: profile_dehydrated_{{ instance }}_config_custom
      - file: profile_dehydrated_{{ instance }}_hook

{%- endfor %} {#- close instance loop #}
