{%- if grains['country'] in ['cz', 'de'] %}
qemu-guest-agent_service:
  service.enabled:
    - name: qemu-guest-agent
{%- endif %}
