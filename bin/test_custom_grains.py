#!/usr/bin/python3

# Validates if the pillar/id/$FQDN.sls has correct custom grains

import os
import sys

import yaml
from get_roles import read_file_skip_jinja
from get_valid_custom_grains import get_countries, get_valid_global_grains


def error_msg(sls, key, valid_values):
    if isinstance(valid_values, str):
        msg = ' is'
        result = valid_values
    else:
        msg = 's are'
        result = ', '.join(valid_values)
    print(f'pillar/id/{sls} has invalid value for the "{key}" key. Valid value{msg}: {result}')
    return 1


def test_custom_grain(mygrains, sls, key, valid_values, status):
    try:
        value = mygrains[key]
    except KeyError:
        print(f'pillar/id/{sls} is missing the "{key}" key')
        return 1

    if isinstance(valid_values, str):
        if value != valid_values:
            status = error_msg(sls, key, valid_values)
    elif valid_values and value not in valid_values:
        status = error_msg(sls, key, map(str, valid_values))

    return status


status = 0

valid_global_grains = get_valid_global_grains()
all_countries = get_countries()

all_ids = sorted(os.listdir('pillar/id'))
for sls in all_ids:
    if sls == 'README.md':
        continue

    content = read_file_skip_jinja("pillar/id/%s" % sls)
    mygrains = yaml.safe_load(content)['grains']

    for key, valid_values in valid_global_grains.items():
        status = test_custom_grain(mygrains, sls, key, valid_values, status)

    if 'country' not in mygrains or mygrains['country'] not in all_countries:
        status = error_msg(sls, 'country', all_countries)

sys.exit(status)
