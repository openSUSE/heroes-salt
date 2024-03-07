{%- set country = grains.get('country') %}

firewalld:
  enable: true
  zones:
    internal:
      interfaces:
        {%- if country == 'cz' %}
        - os-internal
        {%- else %}
        - private
        {%- endif %}
    {%- if country == 'cz' %}
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
