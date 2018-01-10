{% for script in ['check_haproxy_config', 'grep_haproxy_config'] %}

/usr/local/bin/{{ script }}:
  file.managed:
    - source: salt://profile/proxy/files/{{ script }}
    - mode: 755

/etc/haproxy/{{ script }}:
  file.symlink:
    - target: /usr/local/bin/{{ script }}

{% endfor %}
