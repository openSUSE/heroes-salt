#!/bin/bash -u
# vim: noexpandtab

enable dirname mkdir tee whoami

[[ "$(whoami)" == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

source bin/lib/systemctl.sh
source bin/get_colors.sh

role="$1"
IDFILE="pillar/id/$HOSTNAME.sls"

create_fake_certs() {
	mkdir /etc/ssl/services

	mapfile -t pemfiles < \
		<(salt-call --local --out=json pillar.get apache_httpd:vhosts | sed '1{/^jid:/d}' | jq -r '[ .[][] | .SSLCertificateFile, .SSLCertificateKeyFile | select( . != null ) ] | unique | .[]')

	for file in "${pemfiles[@]}"
	do
		mkdir "$(dirname "$file")"
		name="${file##*/}"

		if [[ "$name" == 'fullchain.pem' ]]
		then
			cp test/fixtures/domain.crt "$file"
		elif [[ "$name" == 'privkey.pem' ]]
		then
			cp test/fixtures/domain.key "$file"
		else
			echo "File \"$file\" does not follow the certificate/key naming conventions - it should be named fullchain.pem or privkey.pem."
			status=1
		fi
	done
}

status=0
out="$role.txt"

echo "START OF $role" > "$out"
echo_INFO "Testing role: $role"

printf 'roles:\n- %s' "$role" >> "$IDFILE"

create_fake_certs

echo 'Applying apache_httpd ...' >> "$out"
if salt-call --local state.apply apache_httpd >> "$out"
then
	echo 'Dumping/testing configuration ...' >> "$out"
	mispipe 'apachectl -D DUMP_VHOSTS -t' "tee -a $out" || status=1
else
	status=1
fi

if [[ "$status" == 0 ]]
then
    echo_PASSED
else
    echo_FAILED
    status=1
fi

for dir in conf.d vhosts.d
do
	mkdir "$dir"
	for file in /etc/apache2/"$dir"/*.conf
	do
		cp "$file" "$dir/${file%.conf}.txt"
	done
done

echo "END OF $role" >> "$out"

exit "$status"
