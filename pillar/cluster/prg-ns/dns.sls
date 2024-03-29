{%- import_yaml 'infra/domains.yaml' as domains %}

profile:
  dns:
    powerdns:
      recursor:
        config:
          local_address:
            - '[::1]:1053'
        forward:
          {%- for zone in domains %}
          {{ zone }}:
            - 2a07:de40:b27e:1204::21  # prg-ns1
            - 2a07:de40:b27e:1204::22  # prg-ns2
          {%- endfor %}
