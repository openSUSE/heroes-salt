#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

from ldap3 import Server, Connection, ALL
from get_roles import get_roles, get_roles_of_one_minion
from pathlib import Path
import argparse
import re
import sys
import yaml

spn_regex = r'spn=([\w-]+)@infra\.opensuse\.org,o=heroes' # is there a better way to fetch only the names from kani?

def get_admins_of_a_role(admins, role):
    results = {}
    all_roles = get_roles()
    if role not in all_roles:
        print('Role not found')
        sys.exit(1)

    conn.search('%s' % BASE_DN, '(cn=%s-admins)' % role, attributes=['cn', 'member'])

    try:
        members = conn.entries[0].member
    except IndexError:
        return results

    for file in Path('pillar/id').glob('*.sls'):
        sls = file.name
        minion = file.stem.split('_')[0]
        roles = get_roles_of_one_minion(sls)
        if role in roles:
            for member in members:
                member = re.search(spn_regex, member).group(1)
                results[member] = admins[member]
                results[member]['roles'].append('%s (%s)' % (minion, role))

    return results


def get_admins_of_a_server(admins, server):
    results = {}
    domain = '.infra.opensuse.org'
    if server.endswith(domain):
        minion = server.replace(domain, '')
    else:
        minion = server
        server = f'{server}{domain}'
    server = f'{server.replace(".", "_")}.sls'

    try:
        roles = get_roles_of_one_minion(server)
    except FileNotFoundError:
        print('Server not found')
        sys.exit(1)

    if roles:
        for role in roles:
            for admin, data in admins.items():
                for group in data['groups']:
                    if group.split('-')[0] == role:
                        results[admin] = data
                        results[admin]['roles'].append('%s (%s)' % (minion, role))

    return results


def output_nice(results):
    RESULT_TMPL = '{:^30} {separ} {:^20} {separ} {:^30} {separ} {:^30}'

    print(RESULT_TMPL.format('SERVER (ROLE)', 'USERNAME', 'REAL NAME', 'EMAIL', separ='|'))
    print(RESULT_TMPL.format('', '', '', '', separ='+').replace(' ', '-'))
    for admin, data in sorted(results.items()):
        for role in data['roles']:
            print(RESULT_TMPL.format(role, admin, data['name'], data['mail'], separ='|'))


BASE_DN = 'o=heroes'
admins = {}
EXCLUDE_ACCOUNTS = ['admin', 'guest', 'mufasa', 'monitor', 'wiki']

parser = argparse.ArgumentParser('Collects the admins of a server or of a role, and returns them in a nice output, or as a python dictionary or a yaml hash - will not operate without VPN connectivity!')
parser.add_argument('-o', '--out', choices=['nice', 'yaml', 'python'], help='Select the output format. Options: nice (the default nice output), python (as a python dictionary), yaml (as a yaml hash)')
parser.add_argument('-r', '--role', nargs=1, help='Collect the admins of a given role')
parser.add_argument('-s', '--server', nargs=1, help='Collect the admins of a given server (short name or i.o.o FQDN)')
args = parser.parse_args()

ldap_server = Server('ldap.infra.opensuse.org', get_info=ALL, use_ssl=True)
conn = Connection(ldap_server)
conn.open()
ldap_exclude_accounts = ''
for account in EXCLUDE_ACCOUNTS:
    ldap_exclude_accounts += '(uid=%s)' % account
conn.search('%s' % BASE_DN, '(&(uid=*)(!(|%s)))' % ldap_exclude_accounts, attributes=['uid', 'gecos', 'mail'])
all_admins_from_ldap = conn.entries
for admin in all_admins_from_ldap:
    if len(admin.gecos):
        admins[admin.uid[0]] = {'name': admin.gecos[0], 'mail': admin.mail[0] if len(admin.mail) else 'n/a', 'groups': [], 'roles': []}

conn.search('%s' % BASE_DN, '(&(class=group)(cn=*-admins))', attributes=['cn', 'member'])
all_admin_groups_from_ldap = conn.entries
for group in all_admin_groups_from_ldap:
    members = group.member
    for member in members:
        member = re.search(spn_regex, member).group(1)
        admins[member]['groups'].append(str(group.cn))

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
