#!/usr/bin/python3

# Various roles related tests:
# - Checks if the declared {salt,pillar}/role/*.sls files actually match an
#   assigned role to a minion
# - Checks if the assigned roles to minions have equivalent
#   {salt,pillar}/role/*.sls files
# - Checks that the special roles are not included in any pillar/id/*.sls

import os
import sys
from get_roles import get_roles, get_roles_of_one_minion

status = 0
special_roles = ['base', 'web']
roles = get_roles(append=special_roles)

for directory in ['salt', 'pillar']:
    for sls in os.listdir('%s/role' % directory):
        if sls.endswith('.sls'):
            if sls.split('.sls')[0] not in roles:
                print('%s/role/%s not in roles' % (directory, sls))
                status = 1

for role in roles:
    if not os.path.isfile('salt/role/%s.sls' % role):
        print('%s role is missing the salt/role/%s.sls file' % (role, role))
        status = 1

roles = get_roles()

for special_role in special_roles:
    if special_role in roles:
        for sls in os.listdir('pillar/id/'):
            _roles = get_roles_of_one_minion(sls)
            if special_role in _roles:
                print('%s role should not be included in pillar/id/%s file' % (special_role, sls))
                status = 1

sys.exit(status)
