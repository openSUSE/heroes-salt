{%- set mypillar = salt['pillar.get']('profile:docker', {}) -%}

{%- if 'data_root' in mypillar %}
/etc/sysconfig/docker:
  file.keyvalue:
    - key_values:
        DOCKER_OPTS: '--data-root {{ mypillar['data_root'] }}'
{%- endif %}

docker_service:
  service.running:
    - name: docker
    - enable: true
    {%- if 'data_root' in mypillar %}
    - watch:
      - file: /etc/sysconfig/docker
    {%- endif %}
