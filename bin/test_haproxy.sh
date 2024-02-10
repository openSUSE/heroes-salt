#!/bin/bash
# Script to validate the Salt generated HAProxy configuration
# Georg Pfuetzenreuter <mail@georg-pfuetzenreuter.net>

set -Cu

# systemctl refuses to work in a container, but is needed by service.running. Replace it with /usr/bin/true to avoid useless error messages and breakage.
( cd /usr/bin/ || exit 1 ; ln -sf true systemctl )

loglevel='info'
logbase_salt='log_salt'
logbase_haproxy='log_haproxy'

configfile='/etc/haproxy/haproxy.cfg'
state='profile.proxy.haproxy'

salt () {
	salt-call --local -l "$loglevel" --retcode-passthrough "state.$2" "$3" >> "$1" 2>&1
}

gen_ssl () {
	local ssldir='/etc/ssl/services'

	if [ ! -d "$ssldir" ]
	then
		mkdir /etc/ssl/services
	fi

	while read -r cert
	do
		if [ -n "$cert" ]
		then
			out="$cert"
			if [ -d "$out" ]
			then
				out="${cert}example.com.pem"
			fi
			if [ ! -f "$out" ]
			then
				cat test/fixtures/domain.{crt,key} > "$out"
			fi
		fi
	done <<< "$(grep -hoPr '/etc/(ssl/services/(.*.pem|)|haproxy/.*.crt)' "pillar/cluster/$1/")"
}

check_haproxy () {
	local logfile="$1"
	haproxy -c -f "$configfile" 2>&1 | tee -a "$logfile"
	status="${PIPESTATUS[0]}"

	if [ "$status" = 1 ]
	then
		echo 'Configuration is invalid' | tee -a "$logfile"
		return 1
	fi

	if grep -q 'WARNING' "$logfile"
	then
		echo 'Configuration is valid but problematic' | tee -a "$logfile"
		return 2
	fi

	if [ "$status" -gt 2 ]
	then
		echo 'Unexpected exit code' | tee -a "$logfile"
		return 1
	fi

	echo 'Configuration is alright' | tee -a "$logfile"
	return 0
}

run () {
	local cluster="$1"
	local logfile_haproxy="${logbase_haproxy}_${cluster}.txt"
	local logfile_salt="${logbase_salt}_${cluster}.txt"
	echo "Start of $logfile_haproxy" > "$logfile_haproxy"
	echo "Start of $logfile_salt" > "$logfile_salt"
	if ! salt "$logfile_salt" show_sls "$state"
	then
		tail -n100 "$logfile_salt"
		echo 'State is faulty, not proceeding to test HAProxy.' | tee -a "$logfile_salt" "$logfile_haproxy"
		exit 1
	fi
	gen_ssl "$cluster"
	if ! salt "$logfile_salt" apply "$state"
	then
		tail -n100 "$logfile_salt"
		echo 'State apply failed, not proceeding to test HAProxy.' | tee -a "$logfile_salt" "$logfile_haproxy"
		exit 1
	fi
	check_haproxy "$logfile_haproxy"
	return "$?"
}

if ! { command -v haproxy && command -v salt-call ; } 1>/dev/null
then
	# shellcheck disable=SC2016
	echo 'This script needs `haproxy` and `salt-call`, aborting.'
	exit 1
fi

IDFILE="pillar/id/$(hostname).sls"
printf 'roles:\n- proxy\ninclude:\n'>> "$IDFILE"
test/setup/role/proxy

counter_ok=0
counter_nok=0
counter_wobbly=0
# shellcheck disable=SC2044 # it's reasonable here
for cluster in $(find pillar/cluster/ -maxdepth 1 -mindepth 1 -type d -not -name common -exec sh -c 'cdir="$1"; if grep -lqrm1 haproxy $cdir; then printf "$(basename $cdir)\n"; fi' x {} \;)
do
	echo "Checking $cluster ..."
	printf '%s cluster.%s\n' '-' "$cluster" >> "$IDFILE"
	if run "$cluster"
	then
		counter_ok=$((counter_ok+1))
	else
		if [ "$?" = 2 ]
		then
			counter_wobbly=$((counter_wobbly+1))
		else
			counter_nok=$((counter_nok+1))
		fi
	fi
	cp /etc/haproxy/haproxy.cfg "haproxy_cfg_$cluster.txt"
	sed -i "/$cluster/d" "$IDFILE"
	unset cluster
done

printf 'Good clusters: %i\n' "$counter_ok"
printf 'Clusters with warnings: %i\n' "$counter_wobbly"
printf 'Clusters with errors: %i\n' "$counter_nok"

if [ "$counter_nok" -gt 0 ]
then
	exit 1
fi

if [ "$counter_wobbly" -gt 0 ]
then
	exit 2
fi

exit 0
