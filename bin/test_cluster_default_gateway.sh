#!/bin/sh -efu

grep -lr default_gateway pillar/cluster/ | xargs -L1 dirname | xargs -L1 basename | sort > have
grep -oP '^\w+' pillar/infra/clusters.yaml | sort | \
  grep -v slimhat \
  > want

out="$(comm -13 have want)"
if [ -n "$out" ]
then
  echo 'These clusters are missing a default_gateway declaration:'
  echo "$out"
  exit 1
fi
