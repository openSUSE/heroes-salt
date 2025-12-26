#!/bin/bash

# See the description at the help()

set -e
if [ ! -r /etc/os-release ]; then
    echo "Could not read /etc/os-release - exiting" >&2
    exit 1
fi
source /etc/os-release
SECRETS="False"

if [[ $(whoami) != 'root' ]]; then
    echo 'Can only be run as root'
    exit 1
fi

help() {
    echo "Prepares the CI runner or workstation environment to run highstate or show_highstate tests"
    echo
    echo "Arguments:"
    echo "-g             OPTIONAL: Make preparation for show_highstate"
    echo "-s             OPTIONAL: Include secrets files (disabed because CI runner can't decrypt them due to lack of GPG key)"
    echo "-c             OPTIONAL: Do not install Git formulas"
    echo "-m             OPTIONAL: Do not bootstrap Salt minion"
    echo
}

[[ $1 == '--help' ]] && help && exit

while getopts gschm arg; do
    case ${arg} in
        g) HIGHSTATE=1 ;;
        s) SECRETS="True" ;;
        c) FORMULAS='False' ;;
        m) MINION='False' ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

if [ -z "$FORMULAS" ]
then
  bin/clone_formulas.sh
fi

bin/replace_secrets.sh
rm -fr /srv/{salt,pillar}

ID=$(/usr/bin/hostname -f)
IDFILE="pillar/id/${ID//./_}.sls"
IDFILE_BASE="$IDFILE.base.sls"

printf "grains:\n  site: prg2\n  hostusage: test\n  reboot_safe: no\n" > "$IDFILE"
cp "$IDFILE" "$IDFILE_BASE"

echo 'domain: infra.opensuse.org' > /etc/salt/grains

if [[ -n "$HIGHSTATE" ]]; then
    printf '\nsite: prg2\ninclude_secrets: %s\n' "$SECRETS" >> /etc/salt/grains
    bin/get_roles.py -o yaml >> "$IDFILE"
    cp "$IDFILE_BASE" "$IDFILE"
fi

ln -s "$PWD/salt" /srv/salt

cat > /etc/salt/minion <<-EOF
	disable_modules:
	  - artifactory
	  - bigip
	  - composer
	  - consul
	  - cpan
	  - dnsmasq
	  - gem
	  - genesis
	  - glassfish
	  - gnomedesktop
	  - google_chat
	  - helm
	  - incron
	  - iosconfig
	  - iptables
	  - jboss7
	  - jboss7_cli
	  - k8s
	  - kubeadm
	  - ldapmod
	  - mandrill
	  - mattermost
	  - modjk
	  - msteams
	  - nagios
	  - nagios_rpc
	  - namecheap_domains
	  - namecheap_domains_dns
	  - namecheap_domains_ns
	  - namecheap_ssl
	  - namecheap_users
	  - nexus
	  - nova
	  - npm
	  - nxos
	  - nxos_api
	  - nxos_upgrade
	  - openscap
	  - openstack_config
	  - opsgenie
	  - pagerduty
	  - pagerduty_util
	  - parallels
	  - peeringdb
	  - philips_hue
	  - pip
	  - pushover_notify
	  - pyenv
	  - random_org
	features:
	  x509_v2: true
	EOF

if [ -z "$MINION" ]
then

cat >> /etc/salt/minion <<-EOF

	# Additions from MINION
	file_roots:
	  base:
	    - /srv/salt
	    - /usr/share/salt-formulas/states
	    - /srv/formulas
	pillar_merge_lists: true
	EOF

salt-call --local saltutil.runner saltutil.sync_modules
salt-call --local saltutil.sync_grains
salt-call --local saltutil.sync_modules
salt-call --local saltutil.sync_states

fi   # MINION

# we reference custom modules in the pillar, hence only link it after they are available
ln -s "$PWD/pillar" /srv/pillar

ln -s "$PWD" /srv/salt-git
