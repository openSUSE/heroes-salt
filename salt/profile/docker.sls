{%- set mypillar = salt['pillar.get']('profile:docker', {}) -%}

docker_package:
  pkg.installed:
    - name: docker

{%- if 'data_root' in mypillar %}
/etc/sysconfig/docker:
  file.keyvalue:
    - key_values:
        DOCKER_OPTS: '--data-root {{ mypillar['data_root'] }}'
    - require:
      - pkg: docker_package
{%- endif %}

{%- if 'daemon' in mypillar %}
docker_daemon:
  file.serialize:
    - name: /etc/docker/daemon.json
    - dataset: {{ mypillar['daemon'] }}
    - serializer: json
    - serializer_opts:
      - indent: 2
    - require:
      - pkg: docker_package
    - watch_in:
      - service: docker_service
{%- endif %}

docker_service:
  service.running:
    - name: docker
    - enable: true
    - require:
      - pkg: docker_package
    {%- if 'data_root' in mypillar %}
    - watch:
      - file: /etc/sysconfig/docker
    {%- endif %}
