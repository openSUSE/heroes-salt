#!/usr/bin/python3

# Validates if the pillar/id/$FQDN.sls has correct custom grains

import yaml
import os
import sys

from get_roles import read_file_skip_jinja

def error_msg(sls, key, valid_values):
    if type(valid_values) == str:
        msg = ' is'
        result = valid_values
    else:
        msg = 's are'
        result = ', '.join(valid_values)
    print('pillar/id/%s has invalid value for the "%s" key. Valid value%s: %s' % (sls, key, msg, result))
    return 1


def test_custom_grain(mygrains, sls, key, valid_values, status):
    try:
        value = mygrains[key]
    except KeyError:
        print('pillar/id/%s is missing the "%s" key' % (sls, key))
        return 1

    if type(valid_values) == str:
        if value != valid_values:
            status = error_msg(sls, key, valid_values)
    else:
        if valid_values and value not in valid_values:
            status = error_msg(sls, key, valid_values)

    return status


status = 0

with open('pillar/valid_custom_grains.yaml', 'r') as f:
    VALID_CUSTOM_GRAINS = yaml.load(f)

valid_global_grains = VALID_CUSTOM_GRAINS['global']
all_localized_grains = VALID_CUSTOM_GRAINS['localized']

all_ids = sorted(os.listdir('pillar/id'))
for sls in all_ids:
    content = read_file_skip_jinja("pillar/id/%s" % sls)
    mygrains = yaml.load(content)['grains']

    for key, valid_values in valid_global_grains.items():
        status = test_custom_grain(mygrains, sls, key, valid_values, status)

    try:
        valid_localized_grains = all_localized_grains[mygrains['country']]
        for key, valid_values in valid_localized_grains.items():
            status = test_custom_grain(mygrains, sls, key, valid_values, status)
    except KeyError:
        status = error_msg(sls, 'country', all_localized_grains.keys())

sys.exit(status)
