{%- if pillar.get('nftables') is sameas true %}

nftables_packages:
  pkg.installed:
    - name: nftables-service

nftables_config_base:
  file.managed:
    - name: /etc/nftables.conf
    - contents:
        - '#!/usr/sbin/nft -f'
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - flush ruleset
        - include "/etc/nftables.d/*.nft"

nftables_config_tree:
  file.recurse:
    - name: /etc/nftables.d
    - source: {#- try finding a cluster configuration (hosts with a trailing digit) tree, fall back to a node specific one #}
        - salt://files/nftables/{{ grains['host'][:-1] }}
        - salt://files/nftables/{{ grains['host'] }}
    - dir_mode: '0755'
    - file_mode: '0644'

nftables_service:
  service.running:
    - name: nftables
    - enable: true
    - reload: true
    - require:
        - pkg: nftables_packages
    - watch:
        - file: nftables_config_base
        - file: nftables_config_tree

nftables_status:
  cmd.run:
    - name: systemctl --no-pager status -l nftables
    - require:
        - pkg: nftables_packages
        - file: nftables_config_base
        - file: nftables_config_tree
    - onfail:
        - service: nftables_service

{%- endif %} {#- close nftables pillar check #}
