include:
  - libvirt
  - infrastructure.libvirt
  - profile.idmapd
{%- if
  salt['pillar.get']('infrastructure:domains:' ~ grains['domain'] ~ ':clusters:' ~ grains.get('virt_cluster', '').replace('-bare', '') ~ ':primary')
  ==
  grains['id']
%}
  - profile.fetch-image
{%- endif %}
