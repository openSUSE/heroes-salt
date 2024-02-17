{%- import_yaml 'infra/certificates/macros.yaml' as macros %}
{%- set domain = '.infra.opensuse.org' %}

include:
  - .
{%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.dehydrated.central
{%- endif %}

profile:
  dehydrated:
    instances:
      {%- for instance in ['heroes', 'letsencrypt', 'letsencrypt-test'] %}
      {%- import_yaml 'infra/certificates/' ~ instance ~ '.yaml' as certificates %}
      {{ instance }}:
        {%- if certificates %}
        certificates:
          {%- for certificate, certificate_config in certificates.items() %}
          {%- if 'sans' in certificate_config or 'targets' in certificate_config %}
          {{ certificate }}:

            {%- if 'sans' in certificate_config %}
            sans:
              {%- for san in certificate_config['sans'] %}
              - {{ san }}
              {%- endfor %}
            {%- endif %}

            {%- if 'targets' in certificate_config %}
            targets:
            {%- for target in certificate_config['targets'] %}

              {%- if 'macro' in target and target['macro'] in macros %}
              {%- set macro_config = macros[target['macro']] %}
              {%- for host in macro_config['hosts'] %}
              {{ host ~ domain }}:
                services:
                  {%- for service in macro_config['services'] %}
                  - {{ service }}
                  {%- endfor %}
                  {%- for service in target.get('services', []) %}
                  - {{ service }}
                  {%- endfor %}
              {%- endfor %}

              {%- elif 'host' in target and 'services' in target %}
              {{ target['host'] ~ domain }}:
                services:
                  {%- for service in target['services'] %}
                  - {{ service }}
                  {%- endfor %}
              {%- endif %}
            {%- endfor %} {#- close targets loop #}
            {%- endif %} {#- close targets check #}

          {%- endif %} {#- close sans/targets check #}
          {%- endfor %} {#- close certificates loop #}
        {%- endif %} {#- close certificates check #}
        config:
          {%- if instance == 'heroes' %}
          ca: https://acme.infra.opensuse.org/acme/acme/directory
          {%- else %}
          ca: {{ instance }}
          ocsp_fetch: yes
          {%- endif %}
          {%- if instance == 'letsencrypt-test' %}
          renew_days: 15
          {%- endif %}
      {%- endfor %} {#- close instance loop #}
