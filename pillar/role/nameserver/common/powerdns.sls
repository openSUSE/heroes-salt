powerdns:
  config:
    webserver: 'yes'
    webserver-address: {{ grains['fqdn_ip6'][0] }}
    webserver-allow-from: 2a07:de40:b27e:1100::a/128,2a07:de40:b27e:1203::100/128
    webserver-hash-plaintext-credentials: 'yes'
    webserver-port: 8080
