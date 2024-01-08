{%- import_yaml 'infra/certificates/macros.yaml' as macros %}
{%- set domain = '.infra.opensuse.org' %}

{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.dehydrated.central
{%- endif %}

profile:
  dehydrated:
    instances:
      {%- for instance in ['heroes', 'letsencrypt'] %}
      {%- import_yaml 'infra/certificates/' ~ instance ~ '.yaml' as certificates %}
      {{ instance }}:
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
              {{ host }}{{ domain }}:
                services:
                  {%- for service in macro_config['services'] %}
                  - {{ service }}
                  {%- endfor %}
              {%- endfor %}

              {%- elif 'host' in target and 'services' in target %}
              {{ target['host'] }}{{ domain }}:
                services:
                  {%- for service in target['services'] %}
                  - {{ service }}
                  {%- endfor %}
              {%- endif %}
            {%- endfor %} {#- close targets loop #}
            {%- endif %} {#- close targets check #}

          {%- endif %} {#- close sans/targets check #}
          {%- endfor %} {#- close certificates loop #}
      {%- endfor %} {#- close instance loop #}
