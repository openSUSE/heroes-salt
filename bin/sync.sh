#!/bin/sh -Cu
# Tool for copying the repository contents to all Salt master servers
# Georg Pfuetzenreuter <georg.pfuetzenreuter@suse.com>

git checkout production || exit 1

syncstatus=0

for master in \
	witch1 volva1 volva2
do
	printf 'Transferring to %s ... ' "$master"
	if rsync -a --delete --protect-args --super --chown=cloneboy:salt --chmod='u=rwX,g=rX,o=' --contimeout=20 --timeout=90 . saltpush@"$master".infra.opensuse.org::salt-push
	then
		printf '\e[32m%s\e[0m\n' 'OK'
	else
		syncstatus=1
	fi
	echo
done

exit "$syncstatus"
