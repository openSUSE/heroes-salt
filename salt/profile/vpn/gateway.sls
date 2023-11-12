vpn_gateway_packages:
  pkg.installed:
    - pkgs:
        - openvpn
        - openvpn-auth-pam-plugin

vpn_gateway_config:
  file.managed:
    - names:
      {%- set source = 'salt://profile/vpn/files/' ~ grains['host'] %}
      {%- for file in ['heroes_tcp', 'heroes_udp', 'includes/heroes_common', 'includes/heroes_common_push'] %}
      - /etc/openvpn/{{ file }}.conf:
        - source: {{ source }}/etc/openvpn/{{ file }}.conf.jinja
      {%- endfor %}
    - mode: '06444'
    - template: jinja
    - require:
        - pkg: vpn_gateway_packages

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
