hypervisor_directories:
  file.directory:
    - names:
      {%- for subdir in ['', 'agents', 'disks', 'domains', 'networks', 'os-images', 'nvram'] %}
      - {{ salt['pillar.get']('infrastructure:kvm_topdir') }}/{{ subdir }}
      {%- endfor %}

include:
  - libvirt
  - infrastructure.libvirt.domains
  - profile.idmapd
{%- if
  salt['pillar.get']('infrastructure:domains:' ~ grains['domain'] ~ ':clusters:' ~ grains.get('virt_cluster', '').replace('-bare', '') ~ ':primary')
  ==
  grains['id']
%}
  - profile.fetch-image
{%- endif %}
