#!/usr/bin/env sh
# This will replace all PGP messages in the pillar with the value defined as $substitute. This is handy to avoid "Could not decrypt" errors during local testing.
# Georg Pfuetzenreuter <georg.pfuetzenreuter@suse.com>

substitute="SUBSTITUTED"
searchpath="pillar/secrets/"

find "$searchpath" -type f -name '*.sls' -execdir \
	gawk -i inplace -v subst="$substitute" \
	'{if (FNR==1 && !/#!yaml\|gpg/ && !/#!gpg\|yaml/ && !/#!jinja\|yaml\|gpg/ && !/# empty/){ nextfile }}; !/\|$/{ORS="\n"}; /\|$/{ORS=""; gsub(/\|$/, "")}; /BEGIN PGP MESSAGE/{f=1} !f; /END PGP MESSAGE/{f=0; printf "%s\n", subst};' \
	{} +
