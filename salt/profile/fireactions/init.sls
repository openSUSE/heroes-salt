include:
  - zypper

profile_fireactions_containerd_config:
  file.managed:
    - name: /etc/containerd/config.toml
    - source: salt://{{ slspath }}/files/etc/containerd/config.toml.jinja
    - template: jinja
    - require:
        - pkg: zypper_packages

profile_fireactions_containerd_service:
  service.running:
    - name: containerd
    - enable: true
    - require:
        - pkg: zypper_packages
    - watch:
        - file: profile_fireactions_containerd_config

profile_fireactions_cni_config:
  file.managed:
    - name: /etc/cni/net.d/10-fireactions.conflist
    - source: salt://{{ slspath }}/files/etc/cni/net.d/10-fireactions.conflist
    - require:
        - pkg: zypper_packages

profile_fireactions_config:
  file.managed:
    - name: /etc/fireactions/config.yaml
    - source: salt://{{ slspath }}/files/etc/fireactions/config.yaml.jinja
    - makedirs: true
    - template: jinja

profile_fireactions_service:
  service.running:
    - name: fireactions
    - enable: true
    - reload: false
    - require:
        - pkg: zypper_packages
        - service: profile_fireactions_containerd_service
    - watch:
        - file: profile_fireactions_cni_config
        - file: profile_fireactions_config
