#!/bin/bash

# See the description at the help()

set -e
if [ ! -r /etc/os-release ]; then
    echo "Could not read /etc/os-release - exiting" >&2
    exit 1
fi
source /etc/os-release
SECRETS="False"
PKG=''

if [[ $(whoami) != 'root' ]]; then
    echo 'Can only be run as root'
    exit 1
fi

help() {
    echo "Prepares the CI runner or workstation environment to run highstate or show_highstate tests"
    echo
    echo "Arguments:"
    echo "-p <pkg1,pkg2> Comma-separated list of additional packages to be installed"
    echo "-o <OS>        OPTIONAL: Specify different OS. Examples: \"Leap,15,6\""
    echo "-g             OPTIONAL: Make preparation for show_highstate"
    echo "-s             OPTIONAL: Include secrets files (disabed because CI runner can't decrypt them due to lack of GPG key)"
    echo "-n             OPTIONAL: Delete all repositories to speed up tests which do not install additional packages"
    echo "-c             OPTIONAL: Do not install Git formulas"
    echo
}

[[ $1 == '--help' ]] && help && exit

while getopts p:o:gsnch arg; do
    case ${arg} in
        p) PKG=( ${OPTARG//,/ } ) ;;
        o) OS=( ${OPTARG//,/ } ) ;;
        g) HIGHSTATE=1 ;;
        s) SECRETS="True" ;;
        n) REPOSITORIES='False' ;;
        c) FORMULAS='False' ;;
        h) help && exit ;;
        *) help && exit 1 ;;
    esac
done

DOMAIN='infra.opensuse.org'

if [ -z "$REPOSITORIES" ]
then
  sed -i 's/download.opensuse.org/download-prg.infra.opensuse.org/' /etc/zypp/repos.d/*

  if [ -n "${PKG[*]}" ]; then
      zypper --gpg-auto-import-keys ref
      zypper -qn install --no-recommends "${PKG[@]}"
  fi
elif [ "$REPOSITORIES" == 'False' ]
then
  rm /etc/zypp/repos.d/*
fi

if [ -z "$FORMULAS" ]
then
  bin/clone_formulas.sh
fi

bin/replace_secrets.sh
rm -rf /srv/{salt,pillar} 2>/dev/null

ID=$(/usr/bin/hostname -f)
IDFILE="pillar/id/${ID//./_}.sls"
IDFILE_BASE="$IDFILE.base.sls"

printf "grains:\n  site: prg2\n  hostusage: test\n  reboot_safe: no\n" > "$IDFILE"
cp "$IDFILE" "$IDFILE_BASE"

if [[ -n "$HIGHSTATE" ]]; then
    printf 'site: prg2\ndomain: %s\ninclude_secrets: %s\n' "$DOMAIN" "$SECRETS" > /etc/salt/grains
    [[ -n "${OS[0]}" ]] && printf 'osfullname: %s\nosmajorrelease: %s\nosrelease_info: [%s, %s]\n' "${OS[0]}" "${OS[1]}" "${OS[1]}" "${OS[2]}" >> /etc/salt/grains
    bin/get_roles.py -o yaml >> "$IDFILE"

    if [ ! -d /etc/salt/minion.d ]
    then
	    mkdir /etc/salt/minion.d
    fi
    echo 'features: {"x509_v2": true}' > /etc/salt/minion.d/features_x509_v2.conf
    tee /etc/salt/minion.d/modules.conf <<-EOF
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
	EOF
    tee /etc/salt/minion.d/roots.conf <<-EOF
	file_roots:
	  base:
	    - /srv/salt
	    - /usr/share/salt-formulas/states
	    - /srv/formulas
	EOF

    cp "$IDFILE_BASE" "$IDFILE"
fi

ln -s "$PWD/salt" /srv/salt

salt-call --local saltutil.runner saltutil.sync_runners
salt-call --local saltutil.sync_modules
salt-call --local saltutil.sync_states

# we reference custom modules in the pillar, hence only link it after they are available
ln -s "$PWD/pillar" /srv/pillar

ln -s "$PWD" /srv/salt-git

grep -q search /etc/resolv.conf || echo 'search infra.opensuse.org' >> /etc/resolv.conf
