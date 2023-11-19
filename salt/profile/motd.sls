{%- set os = grains.get('osfullname') %}
{%- if 'motd' in pillar %}

{%- if os == 'Leap' %}
/etc/motd:
  file.prepend:
    - header: true
    - text: {{ pillar['motd'] }}

/etc/motd_fun:
  file.append:
    - name: /etc/motd
    - text: Have a lot of fun ...

{%- elif os == 'openSUSE Tumbleweed' %}
/etc/motd.d/00_salt:
  file.managed:
    - contents_pillar: motd

{%- endif %} {#- close OS checks #}

{%- endif %} {#- close pillar check #}
