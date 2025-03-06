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

list_tmpdir="$(mktemp -dp /dev/shm)"

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

check_haproxy_lists() {
	local logfile="$1"
	local status=0
	local tmpdir="$list_tmpdir"

	pushd "$tmpdir" >/dev/null || exit 1

	while read file
	do
		base="$(basename "$file")"

		if [ -f "$base" ]
		then
			# File was already tested with a previous cluster, no need to repeat as we currently do not have any cluster-specific templating
			# if needed in the future, remove this and adjust cp call at the end
			continue
		fi

		sed '/^####################/d;/THIS FILE IS MANAGED BY SALT/,+6d' "$file" > "$base"

		split_prefix="${base}_split"
		grep -Ev '^$|^##' "$base" | csplit -f "$split_prefix" -sz - '/^#/' '{*}'

		for listfile in "$split_prefix"*
		do
			list="$(head -n1 "$listfile")"
			if [[ "$list" == \#* ]]
			then
				list="${list#\# }"
				list_unsorted="${base}_${list}_unsorted"
				list_sorted="${base}_${list}_sorted"
				sed 1d "$listfile" > "$list_unsorted"
			else
				list="$base"
				list_unsorted="${list}_unsorted"
				list_sorted="${list}_sorted"
				cp "$listfile" "$list_unsorted"
			fi

			sort -u "$list_unsorted" > "$list_sorted"

			while read line
			do
				linestatus=0

				case "$base" in
					networks )
						if [[ ! "$line" =~ / ]]
						then
							echo 'Expected a CIDR mask'
							linestatus=1
						fi
						if ! python3 -c "from ipaddress import ip_network ; import sys ; sys.tracebacklimit = 0 ; ip_network(\"$line\", strict=False)"
						then
							linestatus=1
						fi
					;;
					useragents )
						if [[ ! "$line" =~ ^[a-z0-9]+$ ]]
						then
							echo 'Expected only alphanumeric, lowercase, characters'
							linestatus=1
						fi
					;;
				esac

				if [ "$linestatus" = 1 ]
				then
					echo "Entry \"$line\" in file $file is invalid."
					status=1
				fi
			done < "$list_sorted"

			if diff -u "$list_unsorted" "$list_sorted"
			then
				if [ "$base" = "$list" ]
				then
					echo "File $file is sorted" | tee -a "$logfile"
				else
					echo "Section \"$list\" in file $file is sorted" | tee -a "$logfile"
				fi
			else
				if [ "$base" = "$list" ]
				then
					echo "File $file is not sorted" | tee -a "$logfile"
				else
					echo "Section \"$list\" in file $file is not sorted" | tee -a "$logfile"
				fi

				cp "$list_sorted" "$OLDPWD"/list_"$list_sorted".txt
				status=1
			fi

		done
	done <<< "$(find /etc/haproxy/blacklists -type f)"

	if [ "$status" = 1 ]
	then
		echo 'File is not valid, please correct the issues mentioned above and amend your commit'
	fi

	popd >/dev/null || exit 1

	return "$status"
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
	status_haproxy="$?"

	check_haproxy_lists "$logfile_haproxy"
	status_haproxy_lists="$?"

	if [ "$status_haproxy" = 0 ] && [ "$status_haproxy_lists" = 0 ]
	then
		return 0
	fi

	return 1
}

if ! { command -v haproxy && command -v salt-call ; } 1>/dev/null
then
	# shellcheck disable=SC2016
	echo 'This script needs `haproxy` and `salt-call`, aborting.'
	exit 1
fi

rm /etc/zypp/repos.d/*

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
