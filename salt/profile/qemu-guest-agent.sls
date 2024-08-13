{%- if grains['site'] in ['slc1', 'prg2', 'nue-ipx'] %}
qemu-guest-agent_service:
  service.enabled:
    - name: qemu-guest-agent
{%- endif %}
