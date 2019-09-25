#!/usr/bin/python3

# Validates if the pillar/id/$FQDN.sls has correct custom grains

import yaml
import os
import sys

from get_roles import read_file_skip_jinja
from get_valid_custom_grains import get_valid_global_grains, get_all_valid_localized_grains


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
            status = error_msg(sls, key, map(str, valid_values))

    return status


status = 0

valid_global_grains = get_valid_global_grains()
all_valid_localized_grains = get_all_valid_localized_grains()

all_ids = sorted(os.listdir('pillar/id'))
for sls in all_ids:
    content = read_file_skip_jinja("pillar/id/%s" % sls)
    mygrains = yaml.safe_load(content)['grains']

    for key, valid_values in valid_global_grains.items():
        status = test_custom_grain(mygrains, sls, key, valid_values, status)

    try:
        valid_localized_grains = all_valid_localized_grains[mygrains['country']]
        for ignored_key in ['domains', 'default_domain', 'default_virt_cluster']:
            valid_localized_grains.pop(ignored_key, None)
        for key, valid_values in valid_localized_grains.items():
            status = test_custom_grain(mygrains, sls, key, valid_values, status)
    except KeyError:
        status = error_msg(sls, 'country', all_valid_localized_grains.keys())

sys.exit(status)
