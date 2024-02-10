#!/bin/sh
# GitLab CI clones as root, but some of our containers use a sane user
# https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29022
git config --global --add safe.directory /builds/infra/salt
