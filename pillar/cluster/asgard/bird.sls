bird:
  server:
    filters:

      # filter to allow all our own networks
      openSUSE_PRG2_Out:
        (net ~ openSUSE_PRG2_Networks || net ~ openSUSE_PRG2_Networks_Legacy):
          - 'print "oS OUT, green light for: ", net'
          - accept
        post:
          - 'print "oS OUT, red light for: ", net'
          - reject

      # filter to block all our own networks (used to prevent the backup router from installing routes through the primary)
      openSUSE_PRG2_In:
        (net !~ openSUSE_PRG2_Networks && net !~ openSUSE_PRG2_Networks_Legacy):
          - 'print "oS IN, green light for: ", net'
          - accept
        post:
          - 'print "oS IN, red light for: ", net'
          - reject

      # filter to block direct routes and the TAYGA range
      openSUSE_direct:
        (source = RTS_DEVICE || net = 172.16.164.0/24):
          - reject
        post:
          - accept

    protocols:
      static:
        family: ipv4
        routes:
          # TAYGA
          172.16.164.0/24: 172.16.164.1

      {%- for family, networks in {
                4: [
                    '172.16.128.0/17',
                   ],
                6: [
                    '2a07:de40:b27e::/48',
                   ],
              }.items()
      %}
      ospf{{ family }}:
        type: ospf
        version: 3
        ipv{{ family }}:
          filters:
            import:
              - openSUSE_PRG2_In
            export:
              - openSUSE_PRG2_Out
        areas:
          0:
            interfaces:
              os-asgard:
                type: broadcast
                cost: 10
                hello: 5
              prv1_gate1:
                type: ptp
                cost: 100
                hello: 5
              nueqsc_stonehat:
                type: ptp
                cost: 100
                hello: 5
            networks:
              {%- for network in networks %}
              - {{ network }}
              {%- endfor %}
      {%- endfor %}
