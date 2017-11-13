#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import os
import sys
import yaml


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


def git(cmd, cwd=None):
    # pygit2 is not available for python3 in Leap, use plain git instead

    import subprocess

    status = subprocess.call(['git'] + cmd, cwd=cwd)
    if status != 0:
        sys.exit(status)


def clone_or_pull(CLONE_FROM, CLONE_BRANCH, DEST):
    def use_git_to_clone_or_pull_repo():
        if not os.path.exists(DEST):
            os.mkdir(DEST)
        if os.path.isdir(FULL_PATH):
            git(['pull', '-q'], cwd=FULL_PATH)
        else:
            git(['clone', '-q', url, FULL_PATH] + branch_opts)

    def use_pygit2_to_clone_or_pull_repo():
        import pygit2

        if os.path.isdir(FULL_PATH):
            repo = pygit2.Repository(FULL_PATH)
            repo.checkout('HEAD')
        else:
            pygit2.clone_repository(url, FULL_PATH, bare=False)

    branch_opts = []
    if CLONE_BRANCH:
        branch_opts = ['-b', CLONE_BRANCH, '--single-branch']
    if CLONE_FROM:
        for formula in FORMULAS.keys():
            url = '%s/%s-formula' % (CLONE_FROM, formula)
            FULL_PATH = '%s/%s-formula' % (DEST, formula)
            use_git_to_clone_or_pull_repo()
    else:
        for formula, data in FORMULAS.items():
            namespace = data.get('namespace', 'saltstack-formulas')
            prefix = data.get('prefix', '')
            url = 'https://github.com/%s/%s%s-formula' % (namespace, prefix, formula)
            FULL_PATH = '%s/%s-formula' % (DEST, formula)
            use_git_to_clone_or_pull_repo()


def create_symlinks(DEST):
    for formula in FORMULAS.keys():
        os.symlink('%s/%s-formula/%s' % (DEST, formula, formula), '/srv/salt/%s' % formula)


with open('FORMULAS.yaml', 'r') as f:
    FORMULAS = yaml.load(f)

parser = argparse.ArgumentParser(description='Loads the formulas from FORMULAS.yaml and optionally clones them in a specified destination. Optionally it can also create a symlink from the cloned path to /srv/salt, useful for the CI worker.')
parser.add_argument('-p', '--pull-requests', action='store_true', help='Prints the status of the Pull Requests that are defined in FORMULAS.yaml under "pending".')
parser.add_argument('-d', '--destination', nargs=1, help='Destination absolute path of the cloned (or to-be-cloned) repositories of the formulas.')
parser.add_argument('-c', '--clone', action='store_true', help='Clone the formulas to the destination specified with "--destination". If the repository is already cloned, then it will be pulled/fetched.')
parser.add_argument('--clone-from', nargs=1, help='Specify the git provider to clone from together with the namespace.')
parser.add_argument('--clone-branch', nargs=1, help='Specify the branch to clone.')
parser.add_argument('-s', '--symlink', action='store_true', help='Creates symlink from the specified destination to /srv/salt.')
args = parser.parse_args()

if args.pull_requests:
    check_open_pull_requests()

# Every option below requires the --destination argument to be set
if args.clone or args.symlink or args.clone_from or args.clone_branch:
    if (args.clone_from or args.clone_branch) and not args.clone:
        parser.print_help()
        sys.exit(1)

    if not args.destination or not os.path.isabs(args.destination[0]):
        parser.print_help()
        sys.exit(1)

    if args.clone:
        clone_from = None
        clone_branch = None
        if args.clone_from:
            clone_from = args.clone_from[0]
        if args.clone_branch:
            clone_branch = args.clone_branch[0]
        clone_or_pull(clone_from, clone_branch, args.destination[0])

    if args.symlink:
        create_symlinks(args.destination[0])
else:
    parser.print_help()
    sys.exit(1)
