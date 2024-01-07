{%- set host = grains['host'] %}

{%- from 'map.jinja' import certificate_macros as macros %}
{%- import_yaml 'infra/certificates.yaml' as certificates %}
{%- set _certificates = {} %}

{%- for certificate, certificate_config in certificates.items() %}
{%- for target in certificate_config['targets'] %}

{%- if host == target.get('host') %}
{%- do _certificates.append({certificate: target.get('services', {})}) %}
{%- endif %}

{%- if 'macro' in target and target.get('macro') in macros %}
{%- set macro_config = macros[target['macro']] %}
{%- if host in macro_config['hosts'] %}
{%- if certificate in _certificates %}
{%- do _certificates[certificate].extend(macro_config['services']) %}
{%- else %}
{%- do _certificates.append({certificate: macro_config['services']}) %}
{%- endif %} {#- close certificate in _certificates check #}
{%- endif %} {#- close host in macro hosts check #}
{%- endif %} {#- close macro check #}

{%- endfor %} {#- close target loop #}
{%- endfor %} {#- close certificate loop #}

users:
  cert:
    fullname: Certificate Deployment User
    shell: /bin/sh
    ssh_auth_file:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXfogRapqcAJJOe1S+EYSrFLeNN+1MxDHnfav443GaM dehydrated@acme

{%- if _certificates %}
sudoers:
  users:
    cert:
      {%- for certificate, services in _certificates.items() %}
      {%- for service in services %}
      - '{{ grains['host'] }}=(root) NOPASSWD: /usr/bin/systemctl try-reload-or-restart {{ service }}'
      {%- endfor %}
      {%- endfor %}

profile:
  certificate_target:
    certificates:
      {%- for certificate, services in _certificates %}
      {{ certificate }}: {{ services if services else {} }}
        {{ services }}
      {%- endfor %}
{%- endif %}
