profile:
  dns:
    powerdns:
      recursor:
        forward:
          {%- for zone in [
                'infra.opensuse.org',
              ] %}
          {{ zone }}:
            - 2a07:de40:b27e:1204::21  # prg-ns1
            - 2a07:de40:b27e:1204::22  # prg-ns2
          {%- endfor %}

