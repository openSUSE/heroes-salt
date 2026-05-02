profile_forgejo_server_packages:
  pkg.installed:
    - names:
        - forgejo
        - forgejo-apparmor

profile_forgejo_server_files:
  file.managed:
    - names:
        - /etc/forgejo/conf/app.ini:
            - user: forgejo
            - group: root
            - mode: '0640'
            - source: salt://{{ slspath }}/files/etc/forgejo/conf/app.ini.jinja
            - template: jinja
    - require:
        - pkg: profile_forgejo_server_packages
    - watch_in:
        - service: profile_forgejo_server_service

{%- set branding = salt['pillar.get']('profile:forgejo:server:branding') %}
profile_forgejo_server_templates:
{%- if branding %}
  file.recurse:
    - names:
        - /etc/forgejo/public:
            - source: salt://{{ slspath }}/files/etc/forgejo/public/{{ branding }}
        - /etc/forgejo/templates:
            - source: salt://{{ slspath }}/files/etc/forgejo/templates/{{ branding }}
    - file_mode: '0644'
    - dir_mode: '0755'
    - clean: true
{%- else %}
  file.absent:
    - names:
        - /etc/forgejo/public
        - /etc/forgejo/templates
{%- endif %}
    - require:
        - pkg: profile_forgejo_server_packages
    - watch_in:
        - service: profile_forgejo_server_service

profile_forgejo_server_ssh_key_directory:
  file.directory:
    - name: /etc/forgejo/ssh
    - require:
        - pkg: profile_forgejo_server_packages

{%- for type in ['ecdsa', 'ed25519'] %}
  {%- set keyfile = '/etc/forgejo/ssh/ssh_host_' ~ type ~ '_key' %}
profile_forgejo_server_ssh_key_{{ type }}:
  cmd.run:
    - name: ssh-keygen -t {{ type }} -N '' -f {{ keyfile }}
    - creates: {{ keyfile }}
    - require:
        - pkg: profile_forgejo_server_packages
        - file: profile_forgejo_server_ssh_key_directory

  file.managed:
    - names:
        - {{ keyfile }}:
            - mode: '0640'
        - {{ keyfile }}.pub:
            - mode: '0644'
    - user: root
    - group: forgejo
    - replace: false
    - require:
        - file: profile_forgejo_server_ssh_key_directory
        - cmd: profile_forgejo_server_ssh_key_{{ type }}
    - watch_in:
        - service: profile_forgejo_server_service
{%- endfor %}

profile_forgejo_server_service:
  service.running:
    - name: forgejo
    - enable: true
    - require:
        - pkg: profile_forgejo_server_packages
