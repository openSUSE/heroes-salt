include:
  - libvirt
  - infrastructure.libvirt
  - profile.idmapd
{%- if
  salt['pillar.get']('infrastructure:domains:' ~ grains['domain'] ~ ':clusters:' ~ pillar.get('cluster') ~ ':primary')
  ==
  grains['id']
%}
  - profile.fetch-image
{%- endif %}
