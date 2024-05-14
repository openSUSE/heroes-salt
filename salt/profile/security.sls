security_sysconfig:
  suse_sysconfig.sysconfig:
    - name: security
    - key_values:
        PERMISSION_SECURITY: secure local
        PERMISSION_FSCAPS: ''

security_apply:
  cmd.run:
    - name: chkstat --noheader --system
    - onlyif: chkstat --noheader --system --warn
    - require:
        - suse_sysconfig: security_sysconfig
