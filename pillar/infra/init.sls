#!py
from opensuse_infrastructure_formula.pillar import infrastructure


def run():
    return infrastructure.generate_infrastructure_pillar(['infra.opensuse.org'])
