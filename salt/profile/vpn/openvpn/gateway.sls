vpn_gateway_packages:
  pkg.installed:
    - pkgs:
        - openvpn

vpn_gateway_config:
  file.managed:
    - names:
      {%- set source = 'salt://profile/vpn/openvpn/files/' ~ grains['host'] %}
      {%- for file in ['heroes_tcp', 'heroes_udp', 'includes/heroes_common', 'includes/heroes_common_push'] %}
      - /etc/openvpn/{{ file }}.conf:
        - source: {{ source }}/etc/openvpn/{{ file }}.conf.jinja
      {%- endfor %}
    - mode: '0644'
    - template: jinja
    - require:
        - pkg: vpn_gateway_packages

vpn_gateway_login_directory:
  file.directory:
    - name: /var/log/vpn_logins
    - user: nobody
    - group: manage_vpn_users
    - mode: '0750'

vpn_user_config_directory:
  file.directory:
    - name: /var/lib/vpn_logins
    - user: manage_vpn_users
    - group: manage_vpn_users
    - mode: '0750'

vpn_gateway_scripts:
  file.managed:
    - names:
        {%- for script in [
              'drop_user.sh',
              'log_openvpn_login.sh',
              'manage_inactive_accounts.py',
            ]
        %}
        - /usr/local/bin/{{ script }}:
          - source: salt://profile/vpn/openvpn/files/{{ script }}.jinja
        {%- endfor %}
    - mode: '0755'
    - template: jinja

vpn_user_manage_service:
  file.managed:
    - name: /etc/systemd/system/manage-vpn-users.service
    - mode: '0644'
    - source: salt://profile/vpn/openvpn/files/systemd/manage-vpn-users.service.jinja
    - template: jinja

vpn_user_manage_timer:
  file.managed:
    - name: /etc/systemd/system/manage-vpn-users.timer
    - mode: '0644'
    - source: salt://profile/vpn/openvpn/files/systemd/manage-vpn-users.timer.jinja
    - template: jinja

run_vpn_user_manage_timer:
  service.running:
    - name: manage-vpn-users.timer
    - enable: True

vpn_gateway_services:
  service.running:
    - names:
      - openvpn@heroes_tcp
      - openvpn@heroes_udp
    - enable: true
    - reload: false # reload does not work with user/group "nobody" :(
    - require:
        - pkg: vpn_gateway_packages
        - file: vpn_gateway_config
    - watch:
        - file: vpn_gateway_config

include:
  - .ccd
