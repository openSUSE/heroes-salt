{%- set conntrack = salt['pillar.get']('profile:conntrack') %}

profile_conntrack_module_options:
  file.managed:
    - name: /etc/modprobe.d/00-salt_conntrack.conf
    - template: jinja
    - contents:
      - {{ pillar['managed_by_salt'] | yaml_encode }}
      {%- if 'hashsize' in conntrack %}
      - options nf_conntrack hashsize={{ conntrack['hashsize'] }}
      {%- endif %}

profile_conntrack_module_load:
  kmod.present:
    - name: nf_conntrack
    - persist: true
    - order: 1
    - require:
        - file: profile_conntrack_module_options
