pdns_genrev_packages:
  pkg.installed:
    - name: pdns-genrev

pdns_genrev_sysconfig:
  file.keyvalue:
    - name: /etc/sysconfig/pdns-genrev
    - key_values:
        GENREV_KEY: '{{ pillar['powerdns']['config']['api-key'] }}'
        GENREV_URL: 'http://[::1]:8080'
        ARGS: '"--wet --notify"'
    - require:
      - pkg: pdns_genrev_packages
