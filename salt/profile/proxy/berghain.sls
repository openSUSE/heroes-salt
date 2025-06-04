{%- if salt['pillar.get']('profile:proxy:berghain:enable', false) is sameas true %}
berghain_package:
  pkg.installed:
    - name: berghain

berghain_config:
  file.managed:
    - name: /etc/berghain.yaml
    - source: salt://{{ slspath }}/files/etc/berghain.yaml.jinja
    - template: jinja

berghain_service:
  service.running:
    - name: berghain
    - enable: true
    - reload: false
    - watch:
        - file: berghain_config
    - require:
        - pkg: berghain_package
    - require_in:
      - service: haproxy.service

berghain_haproxy_chroot_bind_mount:
  mount.mounted:
    - name: /var/lib/haproxy/run/berghain
    - device: /run/berghain
    - fstype: none
    - opts: bind
    - persist: true
    - mkmnt: true
    - require:
        - pkg: berghain_package

{%- else %}
berghain_package:
  pkg.removed:
    - name: berghain

haproxy_berghain_spoe_config:
  file.absent:
    - name: /etc/haproxy/spoe.cfg

berghain_config:
  file.absent:
    - name: /etc/berghain.yaml

berghain_haproxy_chroot_bind_mount:
  mount.unmounted:
    - name: /var/lib/haproxy/run/berghain
    - device: /run/berghain
    - persist: true
{%- endif %}
