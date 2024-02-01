keepalived:
  config:
    vrrp_script:
      check_https_port:
        script: '"/usr/bin/socat /dev/null TCP6:{{ grains['fqdn_ip6'][0] | ipwrap }}:443,connect-timeout=1"'
        weight: 2
        interval: 5
        timeout: 2
