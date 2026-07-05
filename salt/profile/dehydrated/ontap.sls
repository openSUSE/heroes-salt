profile_dehydrated_ontap_files:
  file.managed:
    - names:
        - /usr/local/bin/update-ontap-certificate:
            - mode: '0750'
            - source: salt://{{ slspath }}/files/usr/local/bin/update-ontap-certificate.py.jinja
            - template: jinja
        - /home/cert/.netrc:
            - mode: '0440'
            - contents:
                # must not contain comments (no managed header!)
                {%- set netrc = salt['pillar.get']('profile:dehydrated:netrc', {}) %}
                {%- if netrc %}
                  {%- for m, c in netrc | dictsort %}
                - 'machine {{ m }}'
                    {%- for k, v in c.items() %}
                - '{{ k }} {{ v }}'
                    {%- endfor %}
                  {%- endfor %}
                {%- else %}
                - ''
                {%- endif %}
    - user: root
    - group: cert
