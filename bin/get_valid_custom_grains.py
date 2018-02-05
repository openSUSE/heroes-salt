#!/usr/bin/python3

import yaml


def get_valid_custom_grains():
    with open('pillar/valid_custom_grains.yaml', 'r') as f:
        VALID_CUSTOM_GRAINS = yaml.load(f)

    return VALID_CUSTOM_GRAINS


def get_valid_global_grains():
    return get_valid_custom_grains()['global']


def get_all_valid_localized_grains():
    return get_valid_custom_grains()['localized']


def print_valid_localized_grains():
    results = []
    all_valid_localized_grains = get_all_valid_localized_grains()
    for country, items in all_valid_localized_grains.items():
        if type(items['virt_cluster']) == str:
            results.append('%s,%s,%s' % (country, items['city'], items['virt_cluster']))
        elif type(items['virt_cluster']) == list:
            for virt_cluster in items['virt_cluster']:
                results.append('%s,%s,%s' % (country, items['city'], virt_cluster))
    print('\n'.join(results))


if __name__ == "__main__":
    print_valid_localized_grains()
