#!/usr/bin/python3.11
"""
Script to test openSUSE infrastructure data:
- validate files against their respective JSON schema
- test for duplicates where unique values are expected

Copyright (C) 2023 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import json
import sys

import yaml
from jsonschema import Draft202012Validator, ValidationError
from referencing import Registry, Resource

infradir = 'pillar/infra/'
schemadir = f'{infradir}schemas/'
reference = 'draft202012.json'

objects = ['hosts', 'host', 'disk', 'interface']
need_unique = ['ip4', 'ip6', 'pseudo_ip4', 'mac']

schemas = {}
lun_mappers = []

with open(f'{infradir}hosts.yaml') as fh:
    hosts = yaml.safe_load(fh)

for schema in objects + ['reference']:
    with open(f'{schemadir}/{schema}.json') as fh:
        schemas[schema] = json.load(fh)


def _fail(msg=None):
    if msg is not None:
        print(msg)
    sys.exit(1)

def test_schema_meta(data):
    registry = Registry().with_resources(
            [
                ("https://json-schema.org/draft/2020-12/schema", Resource.from_contents(schemas['reference'])),
            ],
    )
    validator = Draft202012Validator(schema=schemas['reference'], registry=registry)
    try:
        if validator.validate(data) is None:
            return True
    except ValidationError as myerror:
        print(f'Schema validation failed! Error in {myerror.json_path}:')
        print(myerror.message)
    _fail('Failed to validate schema against reference schema.')

def test_schema(data):
    for schema in objects:
        print(f'Validating schema "{schema}" against reference schema ...')
        test_schema_meta(schemas[schema])

    print('Preparing to validate hosts ...')
    registry = Registry().with_resources(
            [
                ("infra/schemas/hosts.json", Resource.from_contents(schemas['hosts'])),
                ("infra/schemas/host.json", Resource.from_contents(schemas['host'])),
                ("infra/schemas/disk.json", Resource.from_contents(schemas['disk'])),
                ("infra/schemas/interface.json", Resource.from_contents(schemas['interface'])),
            ],
    )
    validator_hosts = Draft202012Validator(schema=schemas['hosts'], registry=registry)
    validator_host = Draft202012Validator(schema=schemas['host'], registry=registry)

    try:
        validator_hosts.validate(data)
    except ValidationError as myerror:
        print(f'Error in {myerror.json_path}:')
        print(myerror.message)
        _fail('Invalid hosts.yaml file')

    for host, host_config in data.items():
        print(f'Validating {host} ... ', end='')
        try:
            result = validator_host.validate(host_config)
            if result is None:
                print('ok!')
            else:
                print('failed, but unable to determine the cause. :(')
        except ValidationError as myerror:
            print(f'failed! Error in {myerror.json_path}:')
            print(myerror.message)
            return False

    return True

def test_duplicates(data):
    def test_key(key, value):
        if key in need_unique:
            if key not in matches:
                matches.update({key: []})
            matches[key].append(value)
    matches = {}
    for host, host_config in data.items():
        for key, value in host_config.items():
            if isinstance(value, dict):
                for low_key, low_value in value.items():
                    if key == 'disks' and not low_value.endswith(('G', 'GB')):
                        lun_mappers.append(low_value)
                    if isinstance(low_value, (int, str)):
                        test_key(low_key, low_value)
                    elif isinstance(low_value, dict):
                        for low_low_key, low_low_value in low_value.items():
                            test_key(low_low_key, low_low_value)
                    else:
                        _fail(f'Encountered unhandled value type in key {low_key} under host {host}.')
            elif isinstance(value, (int, str)):
                test_key(key, value)
            else:
                _fail(f'Encountered unhandled value type in key {key} under host {host}.')
    unique = {}
    matches['lun_mappers'] = lun_mappers
    need_unique_final = need_unique + ['lun_mappers']
    for need_unique_key in need_unique_final:
        unique.update({need_unique_key:
                       {
                           'seen_values': set(),
                           'duplicate_values': [],
                       },
                    },
        )
    for match_key, match_values in matches.items():
        for match_value in match_values:
            if match_value in unique[match_key]['seen_values']:
                unique[match_key]['duplicate_values'].append(match_value)
            else:
                unique[match_key]['seen_values'].add(match_value)
    found_dupes = False
    for key in need_unique_final:
        dupes = unique[key]['duplicate_values']
        if dupes:
            print(f'FAIL: Duplicate values for key {key}: {dupes}')
            found_dupes = True

    return found_dupes

if __name__ == '__main__':
    checks = {}

    print('Executing schema check ...')
    if test_schema(hosts):
        checks['schema'] = True
    else:
        checks['schema'] = False

    print()
    print('Executing duplicates check ...')
    if test_duplicates(hosts):
        checks['duplicates'] = False
    else:
        checks['duplicates'] = True

    fail = False
    for check, result in checks.items():
        if result is False:
            print()
            print(f'Check "{check}" failed.')
            fail = True

    if fail:
        _fail()
    print()
    print('Infrastructure data is valid.')
