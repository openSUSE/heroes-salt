profile:
  dns:
    powerdns:
      recursor:
        config:
          forward_zones_recurse: '.=[2a07:de40:b27e:1203::11]:53;[2a07:de40:b27e:1203::12]:53'
          lua_dns_script: true
