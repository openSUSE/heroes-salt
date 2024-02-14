{%- set top_directory = '/etc/ssl/services/' %}
{%- set certificates = salt['pillar.get']('profile:certificate_target:certificates', {}) %}

{%- macro crtkey_acl(certificate, name, files, type='user') %}
profile_certificate_target_facl_{{ certificate }}_{{ name }}:
  acl.present:
    - names:
        {%- for file in files %}
        - {{ file }}
        {%- endfor %}
    - acl_type: {{ type }}
    - acl_name: {{ name }}
    - perms: r
    - require:
      - file: profile_certificate_target_directory_{{ certificate }}
{%- endmacro %}

{%- if certificates %}
include:
  - users

profile_certificate_target_hushlogin:
  file.managed:
    - name: /home/cert/.hushlogin
    - replace: False
    - require:
      - file: users_cert_user

profile_certificate_target_directory_top:
  file.directory:
    - name: {{ top_directory }}
    - mode: '0751'
{%- endif %}

{%- for certificate, services in certificates.items() %}
{%- set crt_directory = top_directory ~ certificate %}
{%- set files = {} %}

{%- if 'haproxy' in services %}
{%- do files.update({
      'combined': top_directory ~ certificate ~ '.pem'
    })
%}
{%- endif %}

{%- if 'haproxy' not in services or services | length > 1 %}
{%- do files.update({
      'crt': crt_directory ~ '/fullchain.pem',
      'key': crt_directory ~ '/privkey.pem'
    })
%}
profile_certificate_target_directory_{{ certificate }}:
  file.directory:
    - name: {{ crt_directory }}
    - mode: '0751'
    - require:
      - file: profile_certificate_target_directory_top
{%- else %}
profile_certificate_target_directory_purge_{{ certificate }}:
  file.absent:
    - name: {{ crt_directory }}
{%- endif %}

{%- for file, path in files.items() %}
profile_certificate_target_dummy_{{ file }}_permissions_{{ certificate }}:
  file.managed:
    - name: {{ path }}
    - mode: '0640'
    - user: cert
    - replace: False
    - require:
      - file: profile_certificate_target_directory_top
      {%- if 'haproxy' not in services or services | length > 1 %}
      - file: profile_certificate_target_directory_{{ certificate }}
      {%- endif %}
{%- endfor %}

{%- set individual_files = [files['crt'], files['key']] %}

{#- the following defines ACLs for services which run directly as a service user and read files in their user context
    - as opposed to services such as HAProxy which read certificate/key files as root and then drop privileges #}
{%- if 'pgbouncer' in services %}
{{ crtkey_acl(certificate, 'pgbouncer', individual_files, 'group') }}
{%- endif %}

{%- if 'salined' in services or 'salt-api' in services %}
{{ crtkey_acl(certificate, 'salt', individual_files) }}
{%- endif %}

{%- endfor %} {#- close certificate loop #}

{%- for x in ['d', 'f'] %}
{%- for old in
      salt['file.find'](top_directory, maxdepth=1, mindepth=1, print='name', type=x) |
      difference(
        certificates.keys() if x == 'd' else certificates.keys() | zip_longest('', fillvalue='.pem') | map('join') | list
      )
%}
profile_certificate_target_delete_{{ old }}:
  file.absent:
    - name: {{ top_directory }}{{ old }}
{%- endfor %}
{%- endfor %}
