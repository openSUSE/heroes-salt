bird:
  server:
    filters:

      # filter to allow all our own networks
      openSUSE_SLC1_Out:
        (net ~ openSUSE_SLC1_Networks || net ~ openSUSE_SLC1_Networks_Legacy):
          - 'print "oS OUT, green light for: ", net'
          - accept
        post:
          - 'print "oS OUT, red light for: ", net'
          - reject

      # filter to block all our own networks (used to prevent the backup router from installing routes through the primary)
      openSUSE_SLC1_In:
        (net !~ openSUSE_SLC1_Networks && net !~ openSUSE_SLC1_Networks_Legacy):
          - 'print "oS IN, green light for: ", net'
          - accept
        post:
          - 'print "oS IN, red light for: ", net'
          - reject

      # filter to block direct routes and the TAYGA range
      openSUSE_direct:
        (source = RTS_DEVICE || net = 172.16.127.0/25):
          - reject
        post:
          - accept

    protocols:
      static:
        family: ipv4
        routes:
          # TAYGA
          172.16.127.0/25: 172.16.127.1

      {%- for family, networks in {
                4: [
                    '172.16.112.0/20',
                   ],
                6: [
                    '2a07:de40:617e::/48',
                   ],
              }.items()
      %}
      ospf{{ family }}:
        type: ospf
        version: 3
        ipv{{ family }}:
          filters:
            import:
              - openSUSE_SLC1_In
            export:
              - openSUSE_SLC1_Out
        areas:
          0:
            interfaces:
              os-avalon:
                type: broadcast
                cost: 10
                hello: 5
              prg2_asgard:
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
