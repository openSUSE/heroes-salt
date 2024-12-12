include:
  - .common
  - firewalld
  - multipath
  - nfs.mount
  - suse_ha

{%- if
  salt['pillar.get']('infrastructure:domains:' ~ grains['domain'] ~ ':clusters:' ~ pillar.get('cluster') ~ ':primary')
  ==
  grains['id']
%}
  - profile.fetch-image
{%- endif %}

  - suse_ha.resources
  - infrastructure.suse_ha.resources
  - lunmap
