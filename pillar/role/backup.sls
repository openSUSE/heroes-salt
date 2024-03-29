nfs:
  server:
    exports:
      {%- for i in [1, 2] %}
      /backup/mirrordb{{ i }}:
        mirrordb{{ i }}.infra.opensuse.org:
          - async
          - fsid=0
          - no_root_squash
          - no_subtree_check
          - rw
      {%- endfor %}
