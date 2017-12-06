#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

from ldap3 import Server, Connection, ALL
from get_roles import get_roles, get_roles_of_one_server
import argparse
import os
import sys
import yaml


def get_admins_of_a_role(admins, role):
    results = {}
    all_roles = get_roles()
    if role not in all_roles:
        print('Role not found')
        sys.exit(1)

    conn.search('cn=groups,cn=compat,%s' % BASE_DN, '(cn=%s-admins)' % role, attributes=['cn', 'memberUid'])

    try:
        members = conn.entries[0].memberUid
    except IndexError:
        return results

    for sls in os.listdir('pillar/id'):
        server = sls.split('_')[0]
        roles = get_roles_of_one_server(server)
        if role in roles:
            for member in members:
                results[member] = admins[member]
                results[member]['roles'].append('%s (%s)' % (server, role))

    return results


def get_admins_of_a_server(admins, server):
    results = {}

    try:
        roles = get_roles_of_one_server(server)
    except FileNotFoundError:
        print('Server not found')
        sys.exit(1)

    if roles:
        for role in roles:
            for admin, data in admins.items():
                for group in data['groups']:
                    if group.split('_')[0] == role:
                        results[admin] = data
                        results[admin]['roles'].append('%s (%s)' % (server, role))

    return results


def output_to_pillar():
    with open('pillar/generated/role/monitoring.sls', 'w') as f:
        for admin, data in admins.items():
            del data['roles']
        yaml.dump({'profile': {'monitoring': {'contacts': admins}}}, f, default_flow_style=False)


def output_nice(results):
    RESULT_TMPL = '{:^30} {separ} {:^20} {separ} {:^30} {separ} {:^30}'

    print(RESULT_TMPL.format('SERVER (ROLE)', 'USERNAME', 'REAL NAME', 'EMAIL', separ='|'))
    print(RESULT_TMPL.format('', '', '', '', separ='+').replace(' ', '-'))
    for admin, data in sorted(results.items()):
        for role in data['roles']:
            print(RESULT_TMPL.format(role, admin, data['name'], data['mail'], separ='|'))


BASE_DN = 'dc=infra,dc=opensuse,dc=org'
admins = {}
EXCLUDE_ACCOUNTS = ['admin', 'guest', 'mufasa', 'monitor', 'wiki']

parser = argparse.ArgumentParser('Collects the admins of a server or of a role, and returns them in a nice output, or as a python dictionary or a yaml hash')
parser.add_argument('-o', '--out', choices=['nice', 'yaml', 'python', 'pillar'], help='Select the output format. Options: nice (the default nice output), python (as a python dictionary), yaml (as a yaml hash), pillar (write them to pillar/generated/role/monitoring.sls)')
parser.add_argument('-r', '--role', nargs=1, help='Collect the admins of a given role')
parser.add_argument('-s', '--server', nargs=1, help='Collect the admins of a given server')
args = parser.parse_args()

ldap_server = Server('freeipa.infra.opensuse.org', get_info=ALL)
conn = Connection(ldap_server)
conn.open()
ldap_exclude_accounts = ''
for account in EXCLUDE_ACCOUNTS:
    ldap_exclude_accounts += '(uid=%s)' % account
conn.search('cn=users,cn=accounts,%s' % BASE_DN, '(&(uid=*)(!(|%s)))' % ldap_exclude_accounts, attributes=['uid', 'gecos', 'mail'])
all_admins_from_ldap = conn.entries
for admin in all_admins_from_ldap:
    admins[admin.uid[0]] = {'name': admin.gecos[0], 'mail': admin.mail[0], 'groups': [], 'roles': []}

conn.search('cn=groups,cn=compat,%s' % BASE_DN, '(cn=*-admins)', attributes=['cn', 'memberUid'])
all_admin_groups_from_ldap = conn.entries
for group in all_admin_groups_from_ldap:
    members = group.memberUid
    for member in members:
        group_str = str(group.cn).replace('-', '_')[:-1]
        admins[str(member)]['groups'].append(group_str)

if args.out == 'pillar':
    output_to_pillar()
    sys.exit(0)

if args.role:
    results = get_admins_of_a_role(admins, args.role[0])
elif args.server:
    results = get_admins_of_a_server(admins, args.server[0])
else:
    parser.print_help()
    sys.exit(1)

if results:
    if args.out == 'yaml':
        print(yaml.dump(results, default_flow_style=False))
    elif args.out == 'python':
        print(results)
    else:
        output_nice(results)
