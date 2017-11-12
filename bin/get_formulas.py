#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import os
import sys
import yaml


def git(cmd, cwd=None, additional_env=None):
    # pygit2 is not available for python3 in Leap, use plain git instead

    import subprocess

    env = os.environ.copy()
    if additional_env:
        env.update(additional_env)

    status = subprocess.call(['git'] + cmd, cwd=cwd, env=env)
    if status != 0:
        sys.exit(status)


def clone_or_pull(DEST, SYMLINK=False):
    def use_git_to_clone_or_pull_repo():
        if not os.path.exists(DEST):
            os.mkdir(DEST)
        if os.path.isdir(FULL_PATH):
            git(['pull', '-q'], cwd=FULL_PATH)
        else:
            git(['clone', '-q', url, FULL_PATH])
        git(['remote', 'add', 'opensuse', opensuse_fork_url], cwd=FULL_PATH)
        # TODO: get rid of GIT_SSL_NO_VERIFY as soon as we switch to letsencrypt wildcard certs
        git(['fetch', '-q', 'opensuse'], cwd=FULL_PATH, additional_env={'GIT_SSL_NO_VERIFY': 'true'})

    def use_pygit2_to_clone_or_pull_repo():
        import pygit2

        if os.path.isdir(FULL_PATH):
            repo = pygit2.Repository(FULL_PATH)
            repo.checkout('HEAD')
        else:
            pygit2.clone_repository(url, FULL_PATH, bare=False)

    for formula, data in FORMULAS.items():
        namespace = data.get('namespace', 'saltstack-formulas')
        prefix = data.get('prefix', '')
        url = 'https://github.com/%s/%s%s-formula' % (namespace, prefix, formula)
        opensuse_fork_url = 'https://gitlab.infra.opensuse.org/saltstack-formulas/%s-formula' % formula
        FULL_PATH = '%s/%s-formula' % (DEST, formula)
        use_git_to_clone_or_pull_repo()
        if SYMLINK:
            os.symlink('%s/%s' % (FULL_PATH, formula), '/srv/salt/%s' % formula)


def enable_remote(REMOTE, DEST):
    def use_git_to_enable_remote():
        for formula in FORMULAS.keys():
            FULL_PATH = '%s/%s-formula' % (DEST, formula)
            git(['checkout', '-qB', 'master', '%s/master' % REMOTE], cwd=FULL_PATH)


def check_open_pull_requests():
    from github import Github

    g = Github()
    for formula, data in FORMULAS.items():
        open_pull_requests = data.get('pending', [])
        if open_pull_requests:
            namespace = data.get('original_namespace', 'saltstack-formulas')
            prefix = data.get('prefix', '')
            org = g.get_organization(namespace)
            for pull_request in open_pull_requests:
                pr = int(pull_request.split('/')[-1])
                state = org.get_repo('%s%s-formula' % (prefix, formula)).get_pull(pr).state
                print('%s is %s' % (pull_request, state))


with open('FORMULAS.yaml', 'r') as f:
    FORMULAS = yaml.load(f)

parser = argparse.ArgumentParser(description='Loads the formulas from FORMULAS.yaml and optionally clones them in a specified destination. Optionally it can also create a symlink from the cloned path to /srv/salt, useful for the CI worker. The internal gitlab fork will also be added as secondary remote.')
parser.add_argument('-c', '--clone', action='store_true', help='Clone the formulas to the destination specified with "--destination". The gitlab fork will also be added as remote. If the repository is already cloned, then both remotes will be pulled/fetched.')
parser.add_argument('-s', '--symlink', action='store_true', help='Creates symlink from the specified destination to /srv/salt.')
parser.add_argument('-r', '--remote', nargs=1, help='Enable the specified remote. Available remotes: origin, opensuse. Default: origin')
parser.add_argument('-p', '--pull-requests', action='store_true', help='Prints the status of the Pull Requests that are defined in FORMULAS.yaml under "pending".')
requiredArgs = parser.add_argument_group('required arguments')
requiredArgs.add_argument('-d', '--destination', nargs=1, required=True, help='Destination absolute path of the cloned (or to-be-cloned) repositories of the formulas.')
args = parser.parse_args()

if not os.path.isabs(args.destination[0]):
    parser.print_help()
    sys.exit(1)

if args.remote and args.remote[0] not in ['origin', 'opensuse']:
    parser.print_help()
    sys.exit(1)

if args.clone:
    clone_or_pull(args.destination[0], args.symlink)

if args.remote:
    enable_remote(args.remote[0], args.destination[0])

if args.pull_requests:
    check_open_pull_requests()
