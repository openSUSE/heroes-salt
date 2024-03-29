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
