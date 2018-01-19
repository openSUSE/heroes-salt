#!/usr/bin/python3

# Checks if the declared {salt,pillar}/role/*.sls files actually match an
# assigned role to a minion

import os
import sys
from get_roles import get_roles

status = 0
roles = get_roles(append=['base'])

for directory in ['salt', 'pillar']:
    for sls in os.listdir('%s/role' % directory):
        if sls.endswith('.sls'):
            with open('%s/role/%s' % (directory, sls)) as f:
                if sls.split('.sls')[0] not in roles:
                    print('%s/role/%s not in roles' % (directory, sls))
                    status = 1

for role in roles:
    if not os.path.isfile('salt/role/%s.sls' % role):
        print('%s is missing the salt/role/%s.sls file' % (role, role))
        status = 1

sys.exit(status)
