{%- set mypillar       = salt['pillar.get']('profile:dns:powerdns:recursor', {}) %}
{%- set config         = mypillar.get('config', {}) %}
{%- set addr_self      = mypillar.get('addr_self') %}
{%- set addr_partner   = mypillar.get('addr_partner') %}
{%- set forward_local  = mypillar.get('forward_local', []) %}

{#- servers which recurse to the internet and to authoritative servers on localhost and receive forwards from internal recursors #}
{%- if addr_self and addr_partner %}
{%- do config.update(
      {
        'local_address': [
          '[::1]:1053',
          '[' ~ addr_self ~ ']:1053',
        ],
        'webserver_address': addr_self,
      }
    )
%}
{%- endif %}

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
            config: {{ config }}
            forward: {{ forward_local }}
      - /etc/pdns/pdns.lua:
        - source: salt://profile/dns/powerdns/files/etc/pdns/pdns.lua.jinja
        - template: jinja
        - context:
            nat64_prefix: {{ mypillar.get('nat64_prefix') }}
      - /etc/pdns/forward.conf:
        - contents:
          - {{ pillar['managed_by_salt'] | yaml_encode }}
          {%- if addr_self and addr_partner %}
          {%- for zone in forward_local %}
          - '{{ zone }}={{ addr_self }}, {{ addr_partner }}'
          {%- endfor %}
          {%- endif %}
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
