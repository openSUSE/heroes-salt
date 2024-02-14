#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import os
import sys
from copy import copy

import pygit2
import yaml
from pygit2.errors import GitError


def git(cmd, cwd=None):
    # TODO migrate to pygit2

    import subprocess

    status = subprocess.call(['git'] + cmd, cwd=cwd)
    if status != 0:
        sys.exit(status)


def clone(CLONE_FROM, DEST):
    def clone_repo():
        FULL_PATH = f'{DEST}/{formula}-formula'
        if os.path.isdir(FULL_PATH):
            return

        pygit2.clone_repository(url, FULL_PATH, bare=False)

    if CLONE_FROM:
        for formula in FORMULAS.keys():
            url = f'{CLONE_FROM}/{formula}-formula'
            clone_repo()
    else:
        for formula, data in FORMULAS.items():
            namespace = data.get('namespace', 'saltstack-formulas')
            prefix = data.get('prefix', '')
            url = f'https://github.com/{namespace}/{prefix}{formula}-formula'
            clone_repo()


def create_symlinks(DEST):
    for formula in FORMULAS.keys():
        FULL_PATH = '/srv/salt/%s' % formula
        if not os.path.islink(FULL_PATH):
            os.symlink(f'{DEST}/{formula}-formula/{formula}', FULL_PATH)


def remove_symlinks():
    for formula in FORMULAS.keys():
        FULL_PATH = '/srv/salt/%s' % formula
        if os.path.islink(FULL_PATH):
            os.unlink(FULL_PATH)


def fetch_remote(remote, formula):
    remotecallbacks = None
    if not remote.url.startswith(('http://', 'https://', 'git://', 'ssh://', 'git+ssh://')):
        username = remote.url.split('@')[0]
        credentials = pygit2.KeypairFromAgent(username)
        remotecallbacks = pygit2.RemoteCallbacks(credentials=credentials)
    try:
        remote.fetch(callbacks=remotecallbacks)
    except GitError:
        print(f'{formula}-formula: Failed to fetch remote {remote.name}')


def add_remote(REMOTES, DEST):
    for remote in REMOTES:
        namespace = None
        if len(remote) == 4:
            namespace = remote.pop()

        url = 'https://github.com'
        if len(remote) == 3:
            url = remote.pop()

        prefix = ''
        use_prefix = False
        if not remote[1].startswith('no'):
            use_prefix = True

        name = remote[0]

        for formula, data in FORMULAS.items():
            if not namespace:
                namespace = data.get('namespace', 'saltstack-formulas')
            if use_prefix:
                prefix = data.get('prefix', '')
            if not url.endswith(':'):
                url += '/'
            full_url = f'{url}{namespace}/{prefix}{formula}-formula'
            FULL_PATH = f'{DEST}/{formula}-formula'
            repo = pygit2.Repository(FULL_PATH)
            try:
                repo.create_remote(name, full_url)
            except ValueError:  # remote already exists
                continue
            fetch_remote(repo.remotes[name], formula)


def update(REMOTES, DEST):
    for formula in FORMULAS.keys():
        FULL_PATH = f'{DEST}/{formula}-formula'
        repo = pygit2.Repository(FULL_PATH)
        git(['checkout', '-qB', 'master', 'origin/master'], cwd=FULL_PATH)
        git(['pull', '-q'], cwd=FULL_PATH)
        if REMOTES:
            for remote in REMOTES:
                fetch_remote(repo.remotes[remote], formula)


def push(REMOTES, DEST):
    for formula in FORMULAS.keys():
        FULL_PATH = f'{DEST}/{formula}-formula'
        repo = pygit2.Repository(FULL_PATH)
        git(['checkout', '-qB', 'master', 'origin/master'], cwd=FULL_PATH)
        for remote in REMOTES:
            git(['push', '-qf', remote, 'master'], cwd=FULL_PATH)
            git(['push', '-qf', remote, 'master:production'], cwd=FULL_PATH)
            fetch_remote(repo.remotes[remote], formula)


def checkout_remote_and_branch(REMOTE_BRANCH, DEST):
    for formula in FORMULAS.keys():
        FULL_PATH = f'{DEST}/{formula}-formula'
        branch = REMOTE_BRANCH.split('/')[1]
        git(['checkout', '-qB', branch, REMOTE_BRANCH], cwd=FULL_PATH)


with open('pillar/FORMULAS.yaml', 'r') as f:
    FORMULAS_YAML = yaml.safe_load(f)

FORMULAS = copy(FORMULAS_YAML)['git']

parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='Loads the formulas from FORMULAS.yaml and performs one or more of the operations specified at the arguments.')
parser.add_argument('-d', '--destination', nargs=1, help='Destination absolute path of the cloned (or to-be-cloned) repositories of the formulas.')
parser.add_argument('-f', '--formulas', action='append', nargs='+', help='Specify specific formulas to operate on, instead of working with all the specified FORMULAS.yaml formulas.')
parser.add_argument('-c', '--clone', action='store_true', help='Clone the formulas to the destination specified with "--destination".')
parser.add_argument('--clone-from', nargs=1, help='Specify the git provider to clone from together with the namespace.')
parser.add_argument('-s', '--symlink', action='store_true', help='Creates symlink from the specified destination to /srv/salt.')
parser.add_argument('--remove-symlinks', action='store_true', help='Removes all symlinks that were created in /srv/salt.')
parser.add_argument('-r', '--add-remote', action='append', nargs='+', help='''Add the specified remotes on the local repositories. It can be passed multiple times.
Usage: REMOTE_NAME USE_PREFIXES [GIT_PROVIDER_URL] [NAMESPACE].
       - REMOTE is string
       - USE_PREFIXES should be a string starting with "no" (for no prefix usage), or whatever else string (for prefix usage)
       - GIT_URL (optional) can be in the form "https://gitlab.example.com" or "git@gitlab.example.com:" (make sure you have the trailing colon). If no git provider URL is given, https://github.com will be used.
       - NAMESPACE (optional) is string. If no namespace is given, the one defined in FORMULAS.yaml will be used.
Examples:
         -r forks_ro prefixes
         -r forks_rw prefixes git@github.com:
         -r mycompany no_prefixes https://gitlab.mycompany.com saltstack-formulas
         -r mycompany_forks no_prefixes git@gitlab.mycompany.com: saltstack-formulas''')
parser.add_argument('-u', '--update', nargs='*', help='Switch to origin/master and git pull. Optionally it can accept a list of remotes as arguments, that will be fetched.')
parser.add_argument('-p', '--push', nargs='+', help='Pushes (with --force) to the given list of remotes from origin/master to their master and production branch, and then fetches them.')
parser.add_argument('--checkout', nargs=1, help='Checkout to the specified remote/branch.')
args = parser.parse_args()

will_run = False

if args.remove_symlinks:
    will_run = True
    remove_symlinks()

# Every option below requires the --destination argument to be set
if args.clone or args.symlink or args.clone_from or args.add_remote or isinstance(args.update, list) or args.push or args.checkout:
    will_run = True

    if args.formulas:
        unknown_formulas = []
        args_formulas = []
        FORMULAS = {}

        for sublist in args.formulas:
            for item in sublist:
                args_formulas.append(item)

        for formula in args_formulas:
            try:
                FORMULAS[formula] = FORMULAS_YAML['git'][formula]
            except KeyError:
                unknown_formulas.append(formula)
        if unknown_formulas:
            print("ERROR: The following given formulas are not in FORMULAS.yaml: %s\n" % ', '.join(unknown_formulas), file=sys.stderr)
            sys.exit(1)

    if args.clone_from and not args.clone:
        print('ERROR: Please specify -c / --clone when using --clone-from', file=sys.stderr)
        sys.exit(1)

    if not args.destination or not os.path.isabs(args.destination[0]):
        print('ERROR: The given destination is not an absolute path', file=sys.stderr)
        sys.exit(1)

    if args.add_remote:
        for remote in args.add_remote:
            if len(remote) < 2:
                print('ERROR: At least two parameters are required for -r / --add-remote', file=sys.stderr)
                sys.exit(1)

    if args.clone:
        clone_from = None
        if args.clone_from:
            clone_from = args.clone_from[0]
        clone(clone_from, args.destination[0])

    if args.symlink:
        create_symlinks(args.destination[0])

    if args.add_remote:
        add_remote(args.add_remote, args.destination[0])

    if isinstance(args.update, list):
        update(args.update, args.destination[0])

    if args.push:
        push(args.push, args.destination[0])

    if args.checkout:
        checkout_remote_and_branch(args.checkout[0], args.destination[0])

if not will_run:
    parser.print_help()
    sys.exit(1)
