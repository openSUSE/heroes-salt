include:
  - common.haproxy

profile:
  postfix:
    maincf:
      relayhost: ''
      myhostname: '{{ grains['host'] }}.opensuse.org'
