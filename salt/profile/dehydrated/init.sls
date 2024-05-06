{%- set mypillar = salt['pillar.get']('profile:dehydrated', {}) %}

profile_dehydrated_packages:
  pkg.installed:
    - names:
      - dehydrated:
        # Dehydrated in Leap 15.5 is too old (lacks instantiated services)
        # consider removing if 15.6 ships a more recent version
        - fromrepo: openSUSE:infrastructure
      - python3-dns-lexicon

{%- set instances = mypillar.get('instances', {}) %}
{%- set instance_ns = namespace(targets=[]) %}

{#- first instance/certificates/targets iteration to deduplicate targets used with multiple certificates #}
{%- for instance, instance_config in instances.items() %}
{%- for certificate, certificate_config in instance_config.get('certificates', {}).items() %}
{%- set targets = certificate_config.get('targets', {}) %}

{%- for target in targets.keys() %}
{%- if target not in instance_ns.targets %}
{%- do instance_ns.targets.append(target) %}
{%- endif %} {#- close target in global targets check #}

{%- endfor %} {#- close first targets loop #}
{%- endfor %} {#- close first certificates loop #}
{%- endfor %} {#- close first instances loop #}

{%- for target in instance_ns.targets %}
{%- set host_key = salt['mine.get']([target], 'ssh_host_keys', 'list').get(target, {}).get('ed25519.pub') %}

{%- if host_key is not none %}
profile_dehydrated_known_hosts_{{ target }}:
  ssh_known_hosts.present:
    - name: {{ target }}
    - user: dehydrated
    - key: {{ host_key.split()[1] }}
    - enc: ssh-ed25519
    - hash_known_hosts: False
{%- endif %} {#- close host_key check #}

{%- endfor %} {#- close second targets loop #}

{#- second instances iteration for instance specific states #}
{%- for instance, instance_config in instances.items() %}
{%- set config = mypillar.get('config', {}).copy() %}
{%- do config.update(instance_config.get('config', {})) %}
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
      {%- for dir in ['accounts', 'archive', 'certs', 'chains'] %}
      - {{ topdir }}{{ dir }}:
        - user: dehydrated
        - mode: '0700'
      {%- endfor %}
      {%- for dir in ['config.d', 'hook.d'] %}
      - {{ topdir }}{{ dir }}:
        - mode: '0750'
      {%- endfor %}
      - /var/log/dehydrated-{{ instance }}/deployment_failures:
        - user: dehydrated
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
        - 'BASEDIR={{ topdir }}'
        - 'CONFIG_D="${BASEDIR}config.d"'
        - 'DEHYDRATED_GROUP="dehydrated"'
        - 'DEHYDRATED_USER="dehydrated"'
        - 'DOMAINS_TXT="${BASEDIR}salt-domains.txt"'
        - 'HOOK="${BASEDIR}hook.sh"'
        - 'HOOK_CHAIN="yes"'
        - 'LOCKFILE="/run/dehydrated/lock-{{ instance }}"'
        - 'WELLKNOWN=/var/lib/acme-challenge'
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
        {%- for key, value in config.items() %}
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

{#- second certificates iteration to render certificate specific states #}
{%- for certificate, certificate_config in instance_config.get('certificates', {}).items() %}
{%- do salt.log.debug('dehydrated: parsing certificate ' ~ certificate) %}
{%- set targets = certificate_config.get('targets') %}
{%- set metrics_textfile = '/var/spool/prometheus/dehydrated-hook-' ~ certificate.replace('.', '_') ~ '.prom' %}

{%- if targets %}
profile_dehydrated_{{ instance }}_hook_{{ certificate }}:
  file.managed:
    - name: {{ topdir }}hook.d/{{ certificate }}.sh
    - source: salt://profile/dehydrated/files/etc/dehydrated/hook.d/certificate.sh.jinja
    - template: jinja
    - context:
        instance: {{ instance }}
        certificate: {{ certificate }}
        metrics_textfile: {{ metrics_textfile }}
        targets: {{ targets }}
    - group: dehydrated
    - mode: '0750'
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories

profile_dehydrated_{{ instance }}_hook_{{ certificate }}_prometheus:
  file.managed:
    - name: {{ metrics_textfile }}
    - user: dehydrated
    - group: prometheus
    - mode: '0644'
    - replace: False
{%- endif %}

{%- endfor %} {#- close second certificates loop #}

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
  module.run:
    - name: service.start
    - m_name: dehydrated@{{ instance }}.service
    - onchanges:
      - file: profile_dehydrated_{{ instance }}_config_domains
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_{{ instance }}_sub_directories
      - file: profile_dehydrated_{{ instance }}_config_base
      - file: profile_dehydrated_{{ instance }}_config_custom
      - file: profile_dehydrated_{{ instance }}_hook

{%- endfor %} {#- close instance loop #}
