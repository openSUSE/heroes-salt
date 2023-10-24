{%- set systemd_dir = '/etc/systemd/system' %}
{%- set systemd_units = [] %}

{%- if 'systemd' in pillar %}
{%-   if 'portredirector' in pillar.systemd %}
{%-     for service, service_data in pillar.systemd.portredirector.items() %}

{%-       set service_name         = service ~ ".service" %}
{%-       set socket_name          = service ~ ".socket" %}

{%-       set service_unit         = systemd_dir ~ "/" ~ service_name %}
{%-       set socket_unit          = systemd_dir ~ "/" ~ socket_name %}

{%-       set cleaned_service_name = service.replace('.', '_') %}

{%-       set service_section      = "portredirector_service_" ~ cleaned_service_name %}
{%-       set socket_section       = "portredirector_socket_" ~ cleaned_service_name %}

{%-       do systemd_units.append(service_section) %}
{%-       do systemd_units.append(socket_section) %}

{{ service_section }}:
  file.managed:
    - name: {{ service_unit }}
    - makedirs: true
    - dir_mode: '0755'
    - mode: '0644'
    - user: root
    - group: root
#    - watch_in:
#      - systemd_daemon_reload_port_redirector
    - contents:
      {%- if 'managed_by_salt' in pillar %}
      - "# {{ pillar.managed_by_salt }}"
      {%- endif %}
      - "[Unit]"
      - "Description=Port redirector service {{ service }}"
      - "Requires=network.target"
      - "After=network.target"
      - "#"
      - "[Service]"
      - "ExecStart=/usr/lib/systemd/systemd-socket-proxyd {{ service_data.target }}"
      - "#"
      - "[Install]"
      - "WantedBy=multi-user.target"

{{ socket_section }}:
  file.managed:
    - name: {{ socket_unit }}
    - makedirs: true
    - dir_mode: '0755'
    - mode: '0644'
    - user: root
    - group: root
#    - watch_in:
#      - systemd_daemon_reload_port_redirector
    - contents:
      {%- if 'managed_by_salt' in pillar %}
      - "# {{ pillar.managed_by_salt }}"
      {%- endif %}
      - "[Unit]"
      - "Description=Port redirector service {{ service }}"
      - "#"
      - "[Socket]"
      {%- if "listen_stream" in service_data %}
      {%- for address_port_pair in service_data.listen_stream %}
      - "ListenStream={{ address_port_pair }}"
      {%- endfor %}
      {%- endif %}
      {%- if "listen_datagram" in service_data %}
      {%- for address_port_pair in service_data.listen_datagram %}
      - "ListenDatagram={{ address_port_pair }}"
      {%- endfor %}
      # https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#IPAddressAllow=ADDRESS%5B/PREFIXLENGTH%5D%E2%80%A6
      {%- if "deny_list" in service_data %}
      - "IPAddressDeny={{ service_data.allow_list | join(' ') }}"
      {%- endif %}
      {%- if "allow_list" in service_data %}
      {%- if not("deny_list" in service_data) %}
      - "IPAddressDeny=any"
      {%- endif %}
      - "IPAddressAllow={{ service_data.allow_list | join(' ') }}"
      {%- endif %}
      {%- endif %}
      # https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RestrictAddressFamilies=
      #- "RestrictAddressFamilies=AF_INET AF_INET6"
      - "FreeBind=true"
      - "#"
      - "[Install]"
      - "WantedBy=sockets.target"

enable_{{ socket_section }}:
  service.running:
    - name: {{ socket_name }}
    - enable: True
    - require:
      - {{ socket_section }}
#      - systemd_daemon_reload_port_redirector
    - onchanges:
      - {{ socket_section }}

restart_{{ socket_section }}:
  cmd.run:
    - name: /usr/bin/systemctl restart {{ socket_name }}
    - require:
      - {{ socket_section }}
#      - systemd_daemon_reload_port_redirector
    - onchanges:
      - {{ socket_section }}

restart_{{ service_section }}:
  cmd.run:
    - name: /usr/bin/systemctl restart {{ service_name }}
    - onlyif: /usr/bin/systemctl is-active {{ service_name }}
    - require:
      - {{ service_section }}
#      - systemd_daemon_reload_port_redirector
    - onchanges:
      - {{ service_section }}

disable_{{ service_section }}:
  service.disabled:
    - name: {{ service_name }}
    - enable: False
    - require:
      - {{ service_section }}
#      - systemd_daemon_reload_port_redirector

{%- endfor %}

{#- probably not needed
systemd_daemon_reload_port_redirector:
  module.run:
    - name: service.systemctl_reload
    - onchanges:
    {%- for service in systemd_units %}
      - {{ service }}
    {%- endfor %}
#}
{%-   endif %}
{%- endif %}

