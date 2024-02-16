#!/bin/sh
# Script to clone our repository of unpackaged formulas
# Georg Pfuetzenreuter <mail@georg-pfuetzenreuter.net>
set -Ceu

FORMULASDIR='/srv/formulas'
JOBS="${JOBS:-8}"

if [ -d "$FORMULASDIR" ]
then
  git -C "$FORMULASDIR" pull -j "$JOBS" -q --recurse-submodules
else
  git clone -b production -j "$JOBS" -q --recurse-submodules --single-branch https://gitlab.infra.opensuse.org/infra/salt-formulas-git.git "$FORMULASDIR"
fi
