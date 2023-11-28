profile:
  dns:
    powerdns:
      recursor:
        config:
          allow_from:
            - 2a07:de40:b280:86::/64  # daffy
          local_address:
            - ::1
          forward_zones_recurse: '.=[2a07:de40:b27e:1204::21]:1053;[2a07:de40:b27e:1204::22]:1053'
          lua_dns_script: true
