#!py
"""
vim: ft=python.salt

Orchestration state for updating clustered machines efficiently and (hopefully) safely.

Author: Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>
"""

from pathlib import Path

from yaml import safe_load


def _tgt(tgt):
    return [
            {'tgt': tgt},
            {'tgt_type': 'list'},
    ]

def _salt_fun(fun, tgt, arg=None, kwarg=None, failhard=True):
    params = [
            {'name': fun},
            {'failhard': failhard},
    ] + _tgt(tgt)

    if arg is not None:
        params.append({'arg': arg})

    if kwarg is not None:
        params.append({'kwarg': kwarg})

    return {'salt.function': params}

def _salt_fun_cmd(tgt, cmd, failhard=True):
    return _salt_fun(
            'cmd.run',
            tgt,
            [cmd],
            {'shell': '/bin/sh'},
            failhard,
    )

def _salt_fun_check_http(tgt, port):
    return _salt_fun_cmd(
            tgt,
            (
                'sleep 20 && curl'
                ' --connect-timeout 2'
                ' --max-time 10'
                ' --retry 5'
                ' --retry-connrefused'
                ' --retry-delay 10'
                ' --retry-max-time 180'
                ' --fail-with-body'
                ' --dump-header %'
                ' --no-progress-meter'
                f' localhost:{port}'
            ),
            failhard=True,
    )


def _role_health_check(role, targets):
    if role == 'mariadb':
        return _salt_fun_check_http(targets, 8000)

    # TODO: checks for more roles (gateway, postgresql, ...)

    __salt__['log.error'](f'update-clusters: missing check hook for role "{role}"')

def _role_down(role, targets):
    if role == 'gateway':
        return _salt_fun_cmd(
                targets,
                '/usr/local/sbin/shut_vrrp',
                failhard=True,
        )

def run():
    enabled_waves = __pillar__.get('waves', [])

    if isinstance(enabled_waves, str):
        enabled_waves = [enabled_waves]

    # stages house state functions and will be executed in order
    #   stage1: to assess if minions are online before doing anything
    #   stage2: to assess if minions have necessary software installed
    #   stage3: to assess if minions and their cluster services are healthy
    #   stage4: to bring down cluster services
    #   stage5: install udates (danger starts here)
    states = {'stage1': {}, 'stage2': {}, 'stage3': {}, 'stage4': {}, 'stage5': {}}

    all_targets = []
    waves = {}
    target_roles = {}
    role_targets = {}

    for cluster in enabled_waves:
        roles = []
        targets = []

        for file in Path('/srv/pillar/id').glob(f'{cluster}*.sls'):
            with open(file) as fh:
                iddata = safe_load(fh)

            targets.append(file.stem.replace('_', '.'))

            idroles = iddata['roles']

            if roles:
                if roles == idroles:
                    continue
                else:
                    # if needed we can allow this later, for now abort as a safety precaution in case minions which do not belong together were matched
                    __salt__['log.error'](f'update-clusters: mismatching roles for "{cluster}", aborting.')
                    return

            roles = iddata['roles']


        if not targets:
            __salt__['log.error'](f'update-clusters: no minions found for "{cluster}", aborting.')
            return

        for i, target in enumerate(targets, 1):
            wave = f'wave{i}'

            if wave not in waves:
                waves[wave] = []

            if target in all_targets:
                __salt__['log.error'](f'update-clusters: target "{target}" found in multiple clusters, aborting.')
                return

            all_targets.append(target)
            waves[wave].append(target)

            if roles:
                target_roles[target] = roles

    __salt__['log.info'](f' have target_roles {target_roles}')

    for target, roles in target_roles.items():
        for role in roles:
            if role not in role_targets:
                role_targets[role] = []

            role_targets[role].append(target)

    __salt__['log.info'](f' have role_targets {role_targets}')

    # wave0 contains all nodes from all other waves to more perform preliminary health checks
    # doing these checks for all nodes before walking the individual waves prevents potentially destructive action if not all nodes in a cluster are equally healthy

    wave = 'wave0'

    states['stage1'][f'{wave}-node-ping'] = _salt_fun(
            'test.ping',
            all_targets,
            failhard=True,
    )

    id_check_prereq = f'{wave}-node-check-prerequisites'

    # ensure the os-update script is up to date
    states['stage2'][f'{wave}-node-update-prerequisites'] = {
            'salt.state': [
                {'sls': ['profile.update-os']},
                {'require_in': [{'salt': id_check_prereq}]},
                {'failhard': True},
            ] + _tgt(all_targets),
    }

    states['stage2'][id_check_prereq] = _salt_fun_cmd(
            all_targets,
            '{ command -v jq && command -v update-os ; } >/dev/null',
            failhard=True,
    )

    for role, targets in role_targets.items():
        check = _role_health_check(role, targets)
        if check is None:
            return

        states['stage3'][f'{wave}-node-check-{role}-pre'] = check

    for wave, targets in waves.items():
        __salt__['log.info'](f'update-clusters: wave "{wave}", working with hosts {targets}.')

        hooked_roles = []
        for target in targets:
            for role in target_roles.get(target, []):

                # safety guard to avoid accidentally having multiple nodes of one cluster in the same wave
                # TODO: still allow same roles with nodes from different clusters in one wave
                if role in hooked_roles:
                    __salt__['log.error'](f'update-clusters: role "{role}" encountered multiple times in wave "{wave}", aborting.')
                    return

                hooked_roles.append(role)

                down = _role_down([target], role)
                if down is not None:
                    states['stage4'][f'{wave}-node-down-{role}'] = down

        states['stage5'][f'{wave}-node-update'] = _salt_fun_cmd(
                targets,
                '/usr/local/sbin/update-os',
                failhard=True,
        )

        id_reboot_fire = f'{wave}-node-reboot-fire'
        id_check_failed = f'{wave}-node-check-failed-services'

        states['stage5'][id_reboot_fire] = _salt_fun(
                'system.reboot',
                targets,
                kwarg={
                    'at_time': 0,
                },
        )

        states['stage5'][f'{wave}-node-reboot-wait'] = {
                'salt.wait_for_event': [
                    {'name': 'salt/minion/*/start'},
                    {'id_list': targets},
                    {'timeout': 600},
                    {'require': [{'salt': id_reboot_fire}]},
                    {'require_in': [{'salt': id_check_failed}]},
                ],
        }

        states['stage5'][id_check_failed] = _salt_fun_cmd(
                targets,
                (
                    'systemctl --failed --output json'
                    '| jq '
                    '\'if . != [] then "Failed systemd units found" | halt_error(1) else halt end\''
                ),
        )

        id_dump_failed = f'{wave}-node-dump-failed-services'

        states['stage5'][id_dump_failed] = _salt_fun_cmd(
                targets,
                (
                    'systemctl --failed --quiet'
                    '&& exit 1'
                ),
                failhard=True,
        )
        states['stage5'][id_dump_failed]['salt.function'].append({'onfail': [{'salt': id_check_failed}]})

        for target in targets:
            for role in target_roles.get(target, []):
                check = _role_health_check(role, [target])
                if check is not None:
                    states['stage5'][f'{wave}-node-check-{role}-post'] = check

    out = {}

    for stage_states in states.values():
        out.update(stage_states)

    return out
