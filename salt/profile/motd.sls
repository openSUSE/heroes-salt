{%- if 'motd' in pillar %}

{%- if grains['osfullname'] == 'Leap' and grains['osrelease'] | float < 16 %}
/etc/motd:
  file.managed:
    - contents_pillar: motd

{%- else %}
/etc/motd:
  file.absent

/etc/motd.d/00_salt:
  file.managed:
    - contents_pillar: motd

{%- endif %} {#- close OS checks #}

{%- endif %} {#- close pillar check #}
