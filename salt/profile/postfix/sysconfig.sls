/etc/sysconfig/mail:
  suse_sysconfig.sysconfig:
    - fillup: mail-postfix
    - key_values:
        mail_create_config: '"no"'

/etc/sysconfig/postfix:
  suse_sysconfig.sysconfig:
    - key_values:
        postfix_smtp_tls_server: '"no"'
        postfix_update_maps: '"no"'
