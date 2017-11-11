#!/usr/bin/python3

# Checks if the declared {salt,pillar}/role/*.sls files actually match an
# assigned role to a minion

import os
import sys
from get_roles import get_roles

status = 0

roles = get_roles(with_base=True)

for directory in ['salt', 'pillar']:
    for sls in os.listdir('%s/role' % directory):
        if sls.endswith('.sls'):
            with open('%s/role/%s' % (directory, sls)) as f:
                if sls.split('.sls')[0] not in roles:
                    print ('%s/role/%s not in roles' % (directory, sls))
                    status = 1

sys.exit(status)
