profile_algif_aead:
  file.managed:
    - name: /etc/modprobe.d/00-block-algif_aead.conf
    - contents:
      - {{ pillar['managed_by_salt'] | yaml_encode }}
      - install algif_aead /bin/false

  cmd.run:
    - name: rmmod algif_aead
    - unless: modprobe --dry-run --first-time --quiet algif_aead
