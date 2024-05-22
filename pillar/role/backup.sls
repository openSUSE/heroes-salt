{%- set export_options = [
          'fsid=0',
          'no_root_squash',
          'no_subtree_check',
          'rw',
        ]
%}

nfs:
  server:
    exports:
      {%- for i in [1, 2] %}
      /backup/mirrordb{{ i }}:
        mirrordb{{ i }}.infra.opensuse.org: {{ export_options + ['async'] }}
      {%- endfor %}
      /backup/monitor:
        monitor.infra.opensuse.org: {{ export_options }}
      /backup/falkor:
        {%- for i in [0, 1, 2] %}
        falkor{{ i }}.infra.opensuse.org: {{ export_options }}
        {%- endfor %}
