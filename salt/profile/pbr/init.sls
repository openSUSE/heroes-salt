{%- if salt['pillar.get']('profile:pbr:tables', {}) %}
include:
  - network.wicked.interfaces

profile_pbr_tables:
  file.managed:
    - name: /etc/iproute2/rt_tables
    - source: salt://{{ slspath }}/files/rt_tables.jinja
    - mode: '0644'
    - template: jinja
    - require_in:
        - sls: network.wicked.interfaces

profile_pbr_script:
  file.managed:
    - name: /usr/local/libexec/dopbr
    - source: salt://{{ slspath }}/files/pbr.sh.jinja
    - mode: '0750'
    - template: jinja
    - require_in:
        - sls: network.wicked.interfaces

profile_pbr_reset:
  cmd.run:
    # this is a bit drastic but avoids sub-scripts per table/interface for now
    - name: /usr/local/libexec/dopbr reset all
    - onchanges:
        - file: profile_pbr_script
    - require:
        - file: profile_pbr_tables

{%- else %}
profile_pbr_script:
  cmd.run:
    - name: 'test -x /usr/local/libexec/dopbr && /usr/local/libexec/dopbr pre-down || :'
    - shell: /bin/sh

  file.absent:
    - name: /usr/local/libexec/dopbr
    - require:
        - cmd: profile_pbr_script
{%- endif %}
