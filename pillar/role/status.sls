profile:
  postfix:
    maincf:
      myhostname: {{ grains.host }}.opensuse.org
      relayhost: ''
      smtp_tls_security_level: may
