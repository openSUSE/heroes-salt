{%- set top_directory = '/etc/ssl/services/' %}

include:
  - users

{%- if not salt['file.file_exists']('/home/cert/.hushlogin') %}
profile_certificate_target_hushlogin:
  file.touch:
    - name: /home/cert/.hushlogin
    - require:
      - file: users_cert_user
{%- endif %}

profile_certificate_target_directory_top:
  file.directory:
    - name: {{ top_directory }}
    - mode: '0750'

{%- for certificate, services in salt['pillar.get']('profile:certificate_target:certificates', {}).items() %}
{%- set crt_directory = top_directory ~ certificate %}

{%- set files = {
      'crt': crt_directory ~ '/fullchain.pem',
      'key': crt_directory ~ '/privkey.pem'
    }
%}

profile_certificate_target_directory_{{ certificate }}:
  file.directory:
    - name: {{ crt_directory }}
    - mode: '0750'
    - require:
      - file: profile_certificate_target_directory_top

{%- for file, path in files.items() %}
{%- if not salt['file.file_exists'](path) %}
profile_certificate_target_dummy_{{ file }}:
  file.touch:
    - name: {{ path }}
    - mode: '0640'
    - owner: cert
    - require:
      - file: profile_certificate_target_directory_{{ certificate }}
      - user: users_cert_user
{%- endif %}
{%- endfor %}

{#- as opposed to services such as HAProxy which read certificates as root and then drop privileges,
    pgbouncer only runs as its own user and reads files in its user context #}
{%- if 'pgbouncer' in services %}
profile_certificate_target_facl_{{ certificate }}_pgbouncer:
  acl.present:
    - name: {{ files['key'] }}
    - acl_type: group
    - acl_name: pgbouncer
    - perms: r
    - require:
      - file: profile_certificate_target_directory_{{ certificate }}
{%- endif %}

{%- endfor %} {#- close certificate loop #}
