{%- set site = grains.get('site') %}

firewalld:
  enabled: true
  zones:
    internal:
      interfaces:
        {%- if site == 'prg2' %}
        - os-internal
        {%- else %}
        - private
        {%- endif %}
    {%- if site == 'prg2' %}
      services:
        - http
        - https
    {%- else %}
    public:
      interfaces:
        - external
      services:
        - http
        - https
    {%- endif %}

profile:
  postfix:
    maincf:
      inet_protocols: all
      mydestination: status2.opensuse.org
      myhostname: {{ grains.host }}.opensuse.org
      relayhost: ''
      smtp_tls_security_level: may
