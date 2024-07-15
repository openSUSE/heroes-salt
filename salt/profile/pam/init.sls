pam_config_tree:
  file.recurse:
    - name: /etc/pam.d
    - source: salt://profile/pam/files/etc/pam.d
    - file_mode: '0644'
    # replace pam-config symlinks with regular files
    - follow_symlinks: False
    - template: jinja
