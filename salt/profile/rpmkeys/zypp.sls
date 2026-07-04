include:
  - zypper.repositories

{%- set repositories = salt['pillar.get']('zypper:repositories', {}) %}

{%- if repositories %}
rpmkeys_zypp:
  ini.options_present:
    - names:
      {%- for repository, repository_config in repositories.items() %}
        {%- if 'gpgkey' in repository_config %}
        - /etc/zypp/repos.d/{{ repository }}.repo:
            - sections:
                {{ repository }}:
                  gpgkey: {{ repository_config['gpgkey'] }}
        {%- endif %}
      {%- endfor %}
    - require:
        - sls: zypper.repositories
{%- endif %}
