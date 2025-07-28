include:
  - libvirt
  - infrastructure.libvirt.packages
  - infrastructure.libvirt.directories
{%- set cluster = salt['pillar.get']('infrastructure:domains:' ~ grains['domain'] ~ ':clusters:' ~ pillar.get('cluster')) %}
{%- if not 'primary' in cluster or cluster['primary'] == grains['id'] %}
  - profile.fetch-image
{%- endif %}
  - infrastructure.libvirt.domains
  - profile.idmapd
