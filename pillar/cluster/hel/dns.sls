profile:
  dns:
    powerdns:
      recursor:
        config:
          allow_from:
            - 2a07:de40:b27e::/48
          local_address:
            - ::1
          webserver_allow_from:
            - 2a07:de40:b27e:5001::/64  # VPN
            - 2a07:de40:b27e:5002::/64  # VPN
            - 2a07:de40:b27e:1100::/64  # os-thor
