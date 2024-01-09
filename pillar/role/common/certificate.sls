{%- set host = grains['host'] %}

{%- import_yaml 'infra/certificates/letsencrypt.yaml' as certificates_letsencrypt %}
{%- import_yaml 'infra/certificates/letsencrypt-test.yaml' as certificates_letsencrypt_test %}
{%- import_yaml 'infra/certificates/heroes.yaml' as certificates_heroes %}

{#- target deployment does not support one certificate name being issued from multiple CAs
    duplicates should already be prevented on a YAML validation level, but if in doubt, Let's Encrypt Staging takes priority
#}
{%- set certificates = {} %}
{%- do certificates.update(certificates_heroes) %}
{%- do certificates.update(certificates_letsencrypt) %}
{%- do certificates.update(certificates_letsencrypt_test) %}

{%- import_yaml 'infra/certificates/macros.yaml' as macros %}
{%- set _certificates = {} %}

{%- for certificate, certificate_config in certificates.items() %}
{%- for target in certificate_config['targets'] %}

{%- if host == target.get('host') %}
{%- do _certificates.update({certificate: target.get('services', {})}) %}
{%- endif %}

{%- if 'macro' in target and target.get('macro') in macros %}
{%- set macro_config = macros[target['macro']] %}
{%- if host in macro_config['hosts'] %}
{%- if certificate in _certificates %}
{%- do _certificates[certificate].extend(macro_config['services']) %}
{%- else %}
{%- do _certificates.update({certificate: macro_config['services']}) %}
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
      {%- for certificate, services in _certificates.items() %}
      {{ certificate }}: {{ services if services else {} }}
      {%- endfor %}
{%- endif %}

zypper:
  packages:
    acl: {}
