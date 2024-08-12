{%- if grains['site'] in ['prg2', 'nue-ipx'] %}
qemu-guest-agent_service:
  service.enabled:
    - name: qemu-guest-agent
{%- endif %}
