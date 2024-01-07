{%- for certificate, services in salt['pillar.get']('profile:certificate_target:certificates', {}).items() %}
{%- set directory = '/etc/ssl/' ~ certificate %}

{%- set files = {
      'crt': directory ~ '/fullchain.pem',
      'key': directory ~ '/privkey.pem'
    }
%}

profile_certificate_target_directory_{{ certificate }}:
  file.directory:
    - name: {{ directory }}
    - mode: '0750'

{%- for file, path in files.items() %}
{%- if not salt['file.file_exists'](path) %}
profile_certificate_target_dummy_{{ file }}:
  file.touch:
    - name: {{ path }}
    - mode: '0640'
    - require:
      - file: profile_certificate_target_directory_{{ certificate }}
{%- endif %}
{%- endfor %}

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
