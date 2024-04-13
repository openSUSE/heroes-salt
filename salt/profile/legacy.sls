remove_decommissioned_packages:
  pkg.removed:
    - pkgs:
        - cpupower
        - ethtool
        - golang-github-justwatchcom-elasticsearch_exporter
        - libcpupower1
        - libpci3
        - libpolkit-agent-1-0
        - libpolkit-gobject-1-0
        - polkit
        - python3-configobj
        - python3-linux-procfs
        - python3-pyudev
        {%- if grains['osfullname'] != 'Leap' %}
        - python3-six
        {%- endif %}
        - suse-online-update
        - tuned
        - virt-what
        {%- if grains['virtual'] != 'physical' %}
        - hdparm
        - mdadm
        {%- endif %}

{%- if grains['osfullname'] == 'Leap' %}
{#- remove stock "openSUSE-Leap-15.x-x" repositories duplicating the pillar.osfullname managed repo-oss #}
{%- for repository_file in salt['file.find']('/etc/zypp/repos.d', maxdepth=1, mindepth=1, name='*.repo', type='f') %}
{%- if 'openSUSE-Leap-' in repository_file %}
{{ repository_file }}:
  file.absent
{%- endif %}
{%- endfor %}
{%- endif %}
