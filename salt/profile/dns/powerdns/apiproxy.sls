include:
  - zypper.packages

powerdns_apiproxy_config:
  file.managed:
    - name: /etc/powerdns-api-proxy.yaml
    - source: salt://profile/dns/powerdns/files/etc/powerdns-api-proxy.yaml.jinja
    - template: jinja
    - mode: '0640'
    - user: root
    - group: _powerdns_api_proxy
    - require:
        - pkg: zypper_packages

powerdns_apiproxy_service:
  service.running:
    - name: powerdns-api-proxy
    - enable: true
    - require:
        - pkg: zypper_packages
        - file: powerdns_apiproxy_config
