#!py

def run():
  states = {}

  forward_zones = __salt__['pillar.get']('profile:dns:powerdns:recursor:forward_local')

  if not forward_zones:
    return states

  active_zones = __salt__['cmd.run']('pdnsutil list-all-zones', '').splitlines()

  for zone in active_zones:
    if zone not in forward_zones:
      states[f'profile_dns_powerdns_remove_zone_{zone}'] = {
        'cmd.run': [
          {'name': f'pdnsutil delete-zone {zone}'},
          {'shell': '/bin/sh'},
        ],
      }

  return states
