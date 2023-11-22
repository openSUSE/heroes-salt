{%- for module, count in {'limits': 1, 'mkhomedir': 1, 'sss': 4, 'unix': 4}.items() %}
configure_pam_{{ module }}:
  cmd.run:
    - name: pam-config -a --{{ module }}
    - unless: test $(pam-config -q --{{ module }} | wc -l) = {{ count }}
    - shell: /bin/sh
{%- endfor %}
