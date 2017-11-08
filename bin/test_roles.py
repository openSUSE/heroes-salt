#!/usr/bin/python3

# Collects all the assigned roles of all the minions, and checks if the
# declared {salt,pillar}/role/*.sls files actually match a minion-assigned role

import yaml
import os
import sys

all_roles = ['base']
status = 0

for sls in os.listdir('pillar/id'):
    with open("pillar/id/%s" % sls) as f:
        try:
            _roles = yaml.load(f)['grains']['roles']
        except KeyError:
            continue

        for item in _roles:
            all_roles.append(item)

all_roles = sorted(set(all_roles))

for directory in ['salt', 'pillar']:
    for sls in os.listdir('%s/role' % directory):
        if sls.endswith('.sls'):
            with open('%s/role/%s' % (directory, sls)) as f:
                if sls.split('.sls')[0] not in all_roles:
                    print ('%s/role/%s not in roles' % (directory, sls))
                    status = 1

sys.exit(status)
