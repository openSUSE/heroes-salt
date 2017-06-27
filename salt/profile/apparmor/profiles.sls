{% set profiles = salt['pillar.get']('apparmor:profiles', {}) %}
{% set abstractions = salt['pillar.get']('apparmor:abstractions', {}) %}

{% for profile, data in profiles.items() %}
/etc/apparmor.d/{{ profile }}:
  file.managed:
    - source: {{ data.source }}
    {% if data.has_key('template') %}
    - template: {{ data.template }}
    {% endif %}
    - listen_in:
      - service: apparmor
{% endfor %}

{% for abstraction, data in abstractions.items() %}
/etc/apparmor.d/abstractions/{{ abstraction }}:
  file.managed:
    - source: {{ data.source }}
    {% if data.has_key('template') %}
    - template: {{ data.template }}
    {% endif %}
    - listen_in:
      - service: apparmor
{% endfor %}
