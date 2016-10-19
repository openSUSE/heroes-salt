{% set repositories = salt['pillar.get']('zypper:repositories', {}) %}

{% for repo, data in repositories.items() %}
{{ repo }}:
  pkgrepo.managed:
    - baseurl: {{ data.baseurl }}
{% if data.has_key('priority') %}
    - priority: {{ data.priority }}
{% endif %}
{% if data.has_key('refresh') %}
    - refresh: {{ data.refresh }}
{% endif %}
{% endfor %}
