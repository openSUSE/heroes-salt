include:
  - nginx.config
  - nginx.servers
  {%- if 'snippets' in pillar.get('nginx', {}) %}
  - nginx.snippets
  {%- else %}

/etc/nginx/snippets:
  file.absent
  {%- endif %}

/etc/nginx/ssl:
  file.absent

{%- if grains['osfullname'] != 'openSUSE Tumbleweed' %}
nginx_service_custom:
  file.managed:
    - name: /etc/systemd/system/nginx.service.d/salt.conf
    - makedirs: True
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        - RuntimeDirectory=%N
    - watch_in:
        - service: nginx_service
{%- endif %}
