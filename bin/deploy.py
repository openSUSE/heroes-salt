#!/usr/bin/python3
"""
Script for selectively applying Salt states based on changes in Git
Copyright (C) 2024 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

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

import logging
from argparse import ArgumentParser, RawTextHelpFormatter
from os import environ
from pathlib import PosixPath
from sys import exit

from get_roles import get_minions_with_role, get_roles_of_one_minion
from git import Repo

logging.basicConfig(format='[%(levelname)s] %(message)s')
log = logging.getLogger('salt_deploy')
modes_salt = ['ping', 'test', 'fire']
modes = ['dry'] + modes_salt
cli = False

# late import to avoid logging instance override
try:
  import salt.config
  import salt.loader
  import salt.output
  HAVE_SALT = True
except ImportError:
  HAVE_SALT = False

try:
  from pepper import Pepper
  from pepper.exceptions import PepperException
  HAVE_PEPPER = True
except ImportError:
  HAVE_PEPPER = False


def _fail(msg=None, code=1, exception=None):
  """
  Aborts execution with a given message and an exit code of 1
  """
  if msg:
    log.error(msg)
  if exception and not cli:
    raise exception(msg)
  else:
    exit(code)


def initialize_git(repository=None):
  """
  Initializes a GitPython instance
  """
  if repository is None:
    # parent directory of the script, useful if it resides in <repository>/bin/
    directory = PosixPath(__file__).resolve().parents[1]
  else:
    directory = repository
  log.debug(f'Repository set to {directory}')
  return Repo(directory)


def get_changed_files(repository):
  """
  Returns a list of files which changed in the latest revision
  """
  return repository.git.diff('HEAD~', name_only=True).splitlines()


def normalize_role(role):
  """
  Turns the Path object of a role state file into an appliable state specifier
  """
  # pillar/role/foo/init.sls -> role.foo
  if role.name == 'init.sls':
    return str(role.parent.relative_to(role.parts[0])).replace('/', '.')
  # pillar/role/saltmaster.sls -> role.saltmaster
  # pillar/role/foo/bar.sls -> role.foo.bar
  elif len(role.parents) >= 3 and role.name.endswith('.sls'):
    return str(role.relative_to(role.parts[0]).with_suffix('')).replace('/', '.')
  else:
    _fail(f'Unhandled role construct: {role} - please investigate this.', 3, RuntimeError)


def get_targets(paths):  # noqa: PLR0915  # function needs more statements than usual
  """
  Returns a dictionary of minions and nodegroups affected by
  the given paths to files
  """
  result = {'minions': {}, 'nodegroups': {}, 'patterns': {}}

  def generate_minions_with_role(role):
    """
    Generates a dictionary with all minions a given role is assigned to
    """
    return {minion: role for minion in get_minions_with_role(role.replace('role.', ''))}

  def find_roles_including_profile(profile):
    """
    Returns all roles including a given profile
    """
    roles = []
    role_files = PosixPath('salt').rglob('*.sls')
    for file in role_files:
      with file.open() as fh:
        if profile in fh.read():
          roles.append(normalize_role(file))
    return roles

  def append(state, group='minions', targets=None, do_all_minions=False, do_highstate=False):  # noqa: PLR0912  # logic requires deep nested walking
    """
    Appends the given states to the return dictionary
    """
    log.debug(f'Appending {state}, {group}, {targets}')
    if do_all_minions:
      group='patterns'
      targets=['*']
    elif targets is None:
      if state.startswith('role.'):
        targets = generate_minions_with_role(state.replace('role.', ''))
      elif state.startswith('profile.'):
        targets = {}
        for role in find_roles_including_profile(state):
          if role == 'role.base':
            append(role, do_all_minions=True)
          else:
            for minion, role in generate_minions_with_role(role).items():
              if minion in targets:
                targets[minion].append(role)
              else:
                targets[minion] = [role]
    elif isinstance(targets, str):
      targets = [targets.replace('_', '.')]
    else:
      _fail(f'Cannot detect targets for {state}', 3, RuntimeError)

    if do_highstate:
      state = 'highstate'

    for target in targets:
      if target in result[group]:
        if state not in result[group][target]:
          result[group][target].append(state)
      else:
        result[group][target] = [state]

  for path in paths:
    log.debug(f'Parsing path {path} ...')
    pp = PosixPath(path)
    pps = pp.parts
    ppp = pp.parent
    match pps[0]:
      case 'pillar' | 'salt':
        match pps[1]:
          case 'id':
            for role in get_roles_of_one_minion(pp.stem):
              append(f'role.{role}', 'minions', pp.stem)
          case 'infra':
            match pp.suffix:
              case '.yaml':
                match pp.stem:
                  case 'hosts':
                    append('highstate', 'nodegroups', 'hypervisors')
                  case 'alerts':
                    append('role.monitoring.master')
                  case 'domains':
                    append('role.nameserver.recursor')
                  case 'nameservers' | 'network':
                    append('network', do_all_minions=True)
              case '.sls':
                match pp.stem:
                  case 'init':
                    append('highstate', 'nodegroups', 'hypervisors')
                  case 'nodegroups':
                    append('role.saltmaster')
          case 'role':
            append(normalize_role(pp), do_highstate=True)
          case 'profile':
            profile = None
            # salt/profile/foo/init.sls -> profile.foo
            if pp.name == 'init.sls':
              profile = str(ppp.relative_to(pp.parts[0])).replace('/', '.')
            # salt/profile/foo/bar.sls -> profile.foo.bar
            else:
              profile = str(pp.relative_to(pp.parts[0]).with_suffix('')).replace('/', '.')
            if profile is None:
              _fail(f'Unhandled profile construct {pp} - please patch this!', 3, RuntimeError)
            append(profile)

  return result


def initialize_pepper(debug=False):
  """
  Connects and authenticates to the Salt API,
  returns a Pepper API instance
  """
  apihost = environ.get('pepper_host')
  apiuser = environ.get('pepper_user')
  apipass = environ.get('pepper_secret')

  if apiuser is None or apipass is None:
    _fail('Please set pepper_user and pepper_secret in the environment.', exception=RuntimeError)

  if apihost is None:
    apihost = 'https://witch1.infra.opensuse.org:4550'

  if '@' not in apiuser:
    apiuser = apiuser + '@infra.opensuse.org'

  api = Pepper(api_url=apihost, debug_http=debug)
  try:
    api_login = api.login(apiuser, apipass, 'ldap')
  except PepperException as error:
    _fail(f'Login failed: {error}!', RuntimeError)
  log.debug(api_login)

  return api


class Salt:
  """
  Various operations against a given list of minions or a single
  nodegroup, executed through the given Pepper API instance
  """
  def __init__(self, api, minions=[], nodegroup=None, outdir=None):
    if ( not minions and not nodegroup ) or ( minions and nodegroup ):
      _fail('Illegal use of Salt().', exception=ValueError)

    if isinstance(minions, str):
      minions = [minions]

    self.api = api
    self.minions = minions
    self.nodegroup = nodegroup

    self.opts = salt.config.client_config('~/.config/pepper/master')
    self.modules = salt.loader.minion_mods(self.opts)

    self.pminions = ', '.join(self.minions)
    self.outdir = outdir

    if self.minions:
      if '*' in self.minions:
        self.common_payload = {'tgt': '*', 'tgt_type': 'glob'}
      else:
        self.common_payload = {'tgt': self.minions, 'tgt_type': 'list'}
    elif self.nodegroup:
      self.common_payload = {'tgt': self.nodegroup, 'tgt_type': 'nodegroup'}


  def _print(self, data, opts, outputter='nested'):
    """
    Prints the Salt return data using the given outputter, aims
    to mimic the default `salt` cli behavior by default
    """
    # thanks to saltstack/pepper/blob/develop/pepper/script.py for providing some of this logic
    state_ok = True
    errors = {}
    for entry in data:
      if isinstance(entry, dict):
        for minionid, minionret in entry.items():
          if isinstance(minionret, dict):
            for stateid, stateret in minionret.items():
              if 'result' in stateret:
                if stateret['result'] is False:
                  log.debug(f'Found failure in state {stateid}')
                  state_ok = False
                  if 'comment' in stateret:
                    errors.update({stateret.get('name', stateid): stateret['comment']})

            if 'ret' in minionret:
              salt.output.display_output(
                  {minionid: minionret['ret']},
                  outputter,
                  opts,
              )
          if not isinstance(minionret, dict) or 'ret' not in minionret:
            salt.output.display_output(
                {minionid: minionret},
                outputter,
                opts,
            )

        if not state_ok:
          log.error(errors)

      else:
          salt.output.display_output(
              {'local': entry},
              outputter,
              opts,
          )
    return state_ok

  def _call(self, payload):
    """
    Executes a Salt operation through the Salt API
    """
    opts = self.opts
    if self.outdir:
      opts["output_file"] = f'{self.outdir}/{payload["tgt"]}_{payload["fun"]}.txt'
    result = self.api.low(payload)
    if 'return' in result:
      result = result['return']
    log.debug(result)
    if result and ( ( isinstance(result, list) and result[0] ) or isinstance(result, dict) ):
      if payload['fun'].startswith('state.'):
        if self._print(result, opts=opts, outputter='highstate'):
          return True
      elif self._print(result, opts=opts):
        return True
    else:
      log.warning('Did not return!')
    return False

  def ping(self):
    """
    test.ping
    """
    log.info(f'Attempting to ping {self.pminions} ...')
    payload = {'client': 'local', 'fun': 'test.ping'}
    payload.update(self.common_payload)
    return self._call(payload)

  def update(self, mine=True):
    """
    saltutil.refresh_pillar + mine.update
    """
    results = []
    log.info(f'Refreshing {self.pminions} ...')
    functions = ['saltutil.refresh_pillar']
    if mine:
      functions.append('mine.update')

    for function in functions:
      payload = {'client': 'local', 'fun': function}
      log.info(f'-> {payload["fun"]}')
      payload.update(self.common_payload)
      results.append(self._call(payload))

    if False in results:
      return False

    return True

  def apply(self, state, test=True):
    """
    state.highstate OR state.sls <state>
    """
    action = 'state.highstate' if state == 'highstate' else 'state.sls'
    test_msg = ' in test mode' if test else ''
    log.info(f'Applying {state} on {self.pminions}{test_msg} ...')
    payload = {'client': 'local', 'fun': action, 'arg': state, 'kwarg': {'test': test}}
    payload.update(self.common_payload)
    return self._call(payload)


def coordinate(repository, mode='dry', debug=False, outdir=None, update={'pillar': True, 'mine': True}):  # noqa: PLR0912  # too many nested if's .. hmm
  """
  Base application logic
  """
  if mode not in modes or not isinstance(update, dict):
    ValueError('Invalid function call')
  DO_SALT = False
  if mode in modes_salt:
    DO_SALT = True
  if DO_SALT and not ( HAVE_SALT and HAVE_PEPPER ):
    _fail(f'Packages "salt" and "pepper" are required for the modes {modes_salt}!', exception=ImportError)

  if outdir and not PosixPath(outdir).is_dir():
    _fail(f'Specified directory {outdir} does not exist.', exception=FileNotFoundError)

  targets = get_targets(get_changed_files(initialize_git(repository)))

  if DO_SALT:
    api = initialize_pepper(debug)

  pinged_minions = []
  updated_minions = []
  for group in ['patterns', 'nodegroups', 'minions']:
    log.debug(f'Walking target group "{group}"')
    for target, states in targets.get(group, {}).items():
      log.info(f'{target}: {states}')

      if DO_SALT:
        log.debug(f'Initiating Salt for {target}')
        minion = Salt(api, minions=target, outdir=outdir)

        if target not in pinged_minions and '*' not in pinged_minions:
          log.debug(f'{target}: calling ping()')
          if minion.ping():
            log.debug(f'{target}: ping succeeded')
            pinged_minions.append(target)

          if mode in ['test', 'fire']:
            if target in pinged_minions and target not in updated_minions and '*' not in updated_minions:
              log.debug(f'{target}: calling update()')
              update_mine = update.get('mine', True)
              if ( not update.get('pillar', True) and not update_mine ) or minion.update(mine=update_mine):
                log.debug(f'{target}: update {"succeeded" if update else "skipped"}')
                updated_minions.append(target)

              if minion in updated_minions and 'highstate' in states:
                log.debug(f'{target}: calling apply("highstate")')
                minion.apply('highstate', mode == 'test')
              else:
                for state in states:
                  log.debug(f'{target}: calling apply({state})')
                  minion.apply(state, mode == 'test')

def _main_cli():
  choices = """
  Choices for --mode:
      --mode dry        Skip remote operations, only gather target minions and states
      --mode ping       Ping the target minions
      --mode test       Ping the target minions, refresh their pillar and mine, and apply the states in test=True fashion
      --mode fire       Ping the target minions, refresh their pillar and mine, and apply the states

      The pillar refresh and mine update can be avoided using --no-pillar-refresh and --no-mine-update respectively.

      The "dry" mode can be run without any further requirements.
      All other modes require connectivity to the Salt Master and "pepper_user" as well as "pepper_secret" to be present in the environment.
  """

  argp = ArgumentParser(description='Coordinate and deploy Salt changes',
                        formatter_class=lambda prog: RawTextHelpFormatter(prog,max_help_position=30),
                        epilog=choices,
  )
  argp.add_argument('--repository', help='Set a custom Git repository to operate on (defaults to the parent directory of this script)')
  argp.add_argument('--debug', help='Print very verbose output', action='store_const', dest='loglevel', const=logging.DEBUG, default=logging.INFO)
  argp.add_argument('--api-debug', help='Print very verbose HTTP output', action='store_true')
  argp.add_argument('--mode', '-m', help='Operation mode (defaults to "%(default)s")', choices=modes, default='dry', type=str, metavar='MODE')
  argp.add_argument('--no-pillar-refresh', help='Skip pillar refresh (does not apply in "dry" mode)', action='store_false')
  argp.add_argument('--no-mine-update', help='Skip mine update (does not apply in "dry" mode)', action='store_false')
  # it would be preferable to have --out-dir print _and_ write the output, but unfortunately salt/output/__init__.py line 120 calls an early return
  argp.add_argument('--out-dir', help='When applying states, write the output to files in the specified directory instead of printing it')
  args = argp.parse_args()
  log.setLevel(args.loglevel)

  msg_onlyuseful = 'is not useful in "dry" mode, ignoring.'
  if args.mode == 'dry':
    if args.out_dir:
      log.warning(f'--out-dir {msg_onlyuseful}')
    if not args.no_pillar_refresh:
      log.warning(f'--no-pillar-refresh {msg_onlyuseful}')
    if not args.no_mine_update:
      log.warning(f'--no-mine-update {msg_onlyuseful}')

  coordinate(args.repository, mode=args.mode, debug=args.api_debug, outdir=args.out_dir, update={'pillar': args.no_pillar_refresh, 'mine': args.no_mine_update})

if __name__ == '__main__':
  cli = True
  _main_cli()
