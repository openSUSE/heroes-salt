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
              {%- set target_fqdn = host ~ domain %}
              {{ target_fqdn }}:
                host_key: {{ salt['saltutil.runner']('mine.get', arg=[[target_fqdn], 'ssh_host_keys', 'list']).get(target_fqdn, {}).get('ed25519.pub', 'null') }}
                services:
                  {%- for service in macro_config['services'] %}
                  - {{ service }}
                  {%- endfor %}
              {%- endfor %}

              {%- elif 'host' in target and 'services' in target %}
              {%- set target_fqdn = target['host'] ~ domain %}
              {{ target_fqdn }}:
                host_key: {{ salt['saltutil.runner']('mine.get', arg=[[target_fqdn], 'ssh_host_keys', 'list']).get(target_fqdn, {}).get('ed25519.pub', 'null') }}
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
          {%- endif %}
      {%- endfor %} {#- close instance loop #}
