include:
  - profile.udev

{%- set mypillar = salt['pillar.get']('profile:udev:net', {}) %}

/etc/udev/rules.d/80-salt-net.rules:
{%- if mypillar %}
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        {%- for device, attrs in mypillar | dictsort %}
        - >-
            ACTION=="add"
            KERNEL=="{{ device }}"
            SUBSYSTEM=="net"
            {%- for attr, val in attrs | dictsort %}
            ATTR{{ '{' ~ attr ~ '}' }}="{{ val }}"
            {%- endfor %}
        {%- endfor %}
{%- else %}
  file.absent
{%- endif %}
