{%- set mypillar = salt['pillar.get']('profile:dehydrated', {}) %}

profile_dehydrated_packages:
  pkg.installed:
    - name: dehydrated

profile_dehydrated_config_base:
  file.managed:
    - name: /etc/dehydrated/config
    - group: dehydrated
    - mode: '0640'
    - contens:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - 'DEHYDRATED_USER="dehydrated"'
        - 'DEHYDRATED_GROUP="dehydrated"'
        - 'BASEDIR=/etc/dehydrated/'
        - 'CONFIG_D="${BASEDIR}/config.d"'
        - 'WELLKNOWN=/var/lib/acme-challenge'
        - 'LOCKFILE="/run/dehydrated/lock"'
        - 'HOOK="${BASEDIR}/hooks.sh"'
        - 'DOMAINS_TXT="${BASEDIR}/salt-domains.txt"'
    - require:
      - pkg: profile_dehydrated_packages

profile_dehydrated_config_custom:
  file.managed:
    - name: /etc/dehydrated/config.d/salt.sh
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

profile_dehydrated_config_domains:
  file.managed:
    - name: /etc/dehydrated/salt-domains.txt
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        {%- for certificate, certificate_config in mypillar.get('certificates', {}).items() %}
        - '# CERTIFICATE {{ certificate }} TARGETS {{ certificate.get('targets', [])) }}'
        - '{{ certificate }} {{ ' '.join(certificate.get('sans', [])) }} '
        {%- endfor %}
    - require:
      - pkg: profile_dehydrated_packages

profile_dehydrated_hook:
  file.managed:
    - name: /etc/dehydrated/hooks.sh
    - source: salt://profile/dehydrated/files/etc/dehydrated/hooks.sh.jinja
    - template: jinja
    - group: dehydrated
    - mode: '0750'

profile_dehydrated_timer:
  service.running:
    - name: dehydrated.timer
    - enable: true
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_config_base
      - file: profile_dehydrated_config_custom
      - file: profile_dehydrated_hook

profile_dehydrated_service:
  service.running:
    - name: dehydrated.service
    - onchanges:
      - file: profile_dehydrated_config_domains
    - require:
      - pkg: profile_dehydrated_packages
      - file: profile_dehydrated_config_base
      - file: profile_dehydrated_config_custom
      - file: profile_dehydrated_config_domains
      - file: profile_dehydrated_hook
