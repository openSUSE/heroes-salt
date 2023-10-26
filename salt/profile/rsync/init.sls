{%- if 'rsync' in pillar and 'modules' in pillar.rsync %}
rsyncd_packages:
  pkg.installed:
    - names:
      - rsync

rsyncd_config:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - names:
      - /etc/rsyncd.conf:
        - source: salt://profile/rsync/files/etc/rsyncd.conf.j2

rsyncd_secrets:
  file.managed:
    - user: root
    - group: root
    - mode: '0600'
    - template: jinja
    - names:
      - /etc/rsyncd.secrets:
        - source: salt://profile/rsync/files/etc/rsyncd.secrets.j2

rsyncd_service:
  service.running:
    - name: rsyncd
    - enable: True
    - watch:
      - rsyncd_config
{%- else %}
rsyncd_socket_dead:
  service.dead:
    - name: rsyncd.socket
    - enable: False

rsyncd_service_dead:
  service.dead:
    - name: rsyncd.service
    - enable: False
{%- endif %}
