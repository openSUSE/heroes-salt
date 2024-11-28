{%- import_yaml 'infra/networks.yaml' as networks %}

profile:
  dns:
    powerdns:
      recursor:
        config:
          allow_from:
            - 2a07:de40:617e::/48       # SLC1
            - 2a07:de40:b27e::/48       # PRG2
            - ::1/128
            - fd03:7bbf:d626:1700::/64  # SLC1 os-avalon
            - fda1:21af:580f:1::/127    # SLC1 S2S P2P Avalon1 -> Asgard1
            - fda1:21af:580f:1::2/127   # SLC1 S2S P2P Avalon2 -> Asgard2
          webserver_allow_from:
            - 2a07:de40:b27e:5001::/64  # VPN
            - 2a07:de40:b27e:5002::/64  # VPN
            - 2a07:de40:b27e:1100::/64  # os-thor
        nat64_prefix: {{ networks['pseudo'][grains['site']]['openSUSE-NAT64-Pool']['net6'] }}
