{%- set mypillar = salt['pillar.get']('profile:dns:powerdns:recursor', {}) %}
{%- set forward = mypillar.get('forward', {}) %}

powerdns_recursor_packages:
  pkg.installed:
    - name: pdns-recursor

{#-
note: replace this with file.serialize after Leap has a recent enough pdns-recursor to support YAML style configuration
#}
powerdns_recursor_config:
  file.managed:
    - names:
      - /etc/pdns/recursor.conf:
        - source: salt://profile/dns/powerdns/files/etc/pdns/recursor.conf.jinja
        - template: jinja
        - context:
            config: {{ mypillar.get('config', {}) }}
            forward: {{ forward }}
      - /etc/pdns/pdns.lua:
        - source: salt://profile/dns/powerdns/files/etc/pdns/pdns.lua.jinja
        - template: jinja
      - /etc/pdns/forward.conf:
        - contents:
          - {{ pillar['managed_by_salt'] | yaml_encode }}
          {%- for zone, servers in forward.items() %}
          - '{{ zone }}={{ ', '.join(servers) }}'
          {%- endfor %}
    - mode: '0640'
    - group: pdns
    - require:
      - pkg: powerdns_recursor_packages

powerdns_recursor_service:
  service.running:
    - name: pdns-recursor
    - enable: true
    - require:
      - pkg: powerdns_recursor_packages
    - watch:
      - file: powerdns_recursor_config
