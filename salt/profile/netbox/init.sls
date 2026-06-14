include:
  - profile.docker

netbox-docker-compose-installed:
  pkg.installed:
    - pkgs:
      - docker-compose

netbox-clone-repository:
  git.latest:
    - name: https://github.com/SUSE/netbox-docker.git
    - target: /opt/netbox-docker
    - branch: suse-main
    - rev: suse-main
    - user: root
    # TODO
    #- force_reset: True
    - sync_tags: False

netbox-env-directory:
  file.directory:
    - name: /etc/opt/netbox-docker

{%- set datadir = '/var/opt/netbox' %}
netbox-data-directory-top:
  file.directory:
    - name: {{ datadir }}

netbox-data-directory-sub:
  file.directory:
    - names:
        {%- for subdir in [
              'data-source',
              'reports',
              'scripts',
            ]
        %}
        - {{ datadir }}/{{ subdir }}
        {%- endfor %}
        - {{ datadir }}/media:
            - user: 999
            - group: root
            - mode: '0750'
            - recurse:
                - user
                - group
    - require:
        - file: netbox-data-directory-top

netbox-env-files:
  file.managed:
    - names:
        {%- for file in [
              'compose',
              'netbox',
              'redis',
              'redis-cache',
            ]
        %}
        - /etc/opt/netbox-docker/{{ file }}.env:
            - source: salt://{{ slspath }}/files/{{ file }}.env.jinja
        {%- endfor %}
    - template: jinja
    - mode: '0640'
    - user: root
    - group: root
    - require:
        - file: netbox-env-directory

{%- set versiontag = pillar['profile']['netbox']['versiontag'] %}
netbox-build:
  cmd.run:
    - cwd: /opt/netbox-docker
    - name: ./build-suse.sh {{ versiontag.replace('-suse', '') }}
    - unless: 'test "$(docker images --format ''{% raw %}{{.Tag}}{% endraw %}'' netbox:{{ versiontag }})" = {{ versiontag }}'
    - require:
        - file: netbox-data-directory-sub
        - file: netbox-env-directory
        - file: netbox-env-files
        - pkg: netbox-docker-compose-installed
        - service: docker_service
    - shell: /bin/sh

netbox-up:
  cmd.run:
    - cwd: /opt/netbox-docker
    - name: /usr/bin/docker-compose --env-file /etc/opt/netbox-docker/compose.env up -d --no-build
    - onchanges:
        - file: netbox-env-files
    - require:
        - cmd: netbox-build
        - file: netbox-data-directory-sub
        - file: netbox-env-directory
        - file: netbox-env-files
        - pkg: netbox-docker-compose-installed
        - service: docker_service
    - shell: /bin/sh
