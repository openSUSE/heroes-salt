#!/bin/bash
STATUS=0

# Validate the salt-generated nginx configs

rpm -qa --qf '%{name}\n' | sort > /tmp/packages-before

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

source bin/lib/systemctl.sh
source bin/get_colors.sh

role="$1"
IDFILE="pillar/id/$HOSTNAME.sls"

create_fake_certs() {
    # install dummy certificates and keys as valid files are needed for the nginx config test

    local role="${role/.//}"
    mapfile -t pemfiles < <(salt-call --local --out=json pillar.get nginx:servers | sed '1{/^jid:/d}' | jq -r '.[][][]["config"][]["server"] | select( . != null ) [] | .ssl_certificate, .ssl_certificate_key | select( . != null )')

    for file in "${pemfiles[@]}"
    do
      if [[ ${file##*.} =~ pem ]]
      then
          name="${file##*/}"
          mkdir "$(dirname "$file")"

          if [[ "$name" =~ cert|fullchain ]]
          then
            cp test/fixtures/domain.crt "$file"
          elif [[ "$name" =~ key ]]
          then
            cp test/fixtures/domain.key "$file"
          else
            echo "pillar/role/$role.sls => $file does not match one of 'cert', 'fullchain', 'key'!"
            STATUS=1
            continue
          fi
      else
          echo "pillar/role/$role.sls => $file should have extension '.pem'!"
          STATUS=1
          continue
      fi
    done
}

touch_includes() {
    case "$role" in
        mailman3)
            touch /etc/nginx/mails.rewritemap
            touch /etc/nginx/lists.rewritemap
            touch /etc/nginx/feeds.rewritemap
            touch /etc/nginx/mboxs.rewritemap
            touch /etc/nginx/miscs.rewritemap
            ;;
        pagure)
            touch /etc/nginx/acme-challenge
            mkdir -p /etc/ssl/services/letsencrypt
            cat test/fixtures/domain.{crt,key} > /etc/ssl/services/letsencrypt/code.opensuse.org.with.chain_rsa.pem
            cat test/fixtures/domain.{crt,key} > /etc/ssl/services/letsencrypt/code.opensuse.org.with.chain_ecdsa.pem
            sed '/ ssl_dhparam / d' -i /etc/nginx/ssl-config
            ;;
    esac;
}

rolestatus=0
sls_role="salt/role/${role/./\/}.sls"
out="$role.txt"
echo "START OF $role" > "$out"
echo_INFO "Testing role: $role"

rm /etc/zypp/repos.d/*

printf 'roles:\n- %s' "$role" >> "$IDFILE"

# Reset the grains-retrieved IPs to 127.0.0.1, as `nginx -t` actually tries
# to bind to any configured listen IP
sed -i -e "s/{{ ip4_.* }}/127.0.0.1/g" "pillar/role/$role.sls"

# RuntimeDirectory
mkdir /run/nginx

# no fancyindex is installed in the test environment, adding it would require switching nginx to devel
if [ "$role" = 'mirror.internal' ]
then
  sed -i \
    -e '/^  server:/d;/^    config:/d;/load_module:/d;/fancyindex/d' \
    -e '/http2:/d' \
    pillar/role/mirror/internal.sls
fi

if grep -q profile "$sls_role"
then
    #for profile in "$(grep -h '\- profile' $sls_role | yq -o t)" // to-do: add yq to container
    for profile in $(grep -h '\- profile' "$sls_role" | sed 's/^\s\+ -//' | tr '\n' ' ')
    do
        if [ ! "$profile" == 'profile.web.server.nginx' ]
        then
            dir_profile="${profile//./\/}"
            if [ -f "salt/$dir_profile/nginx.sls" ]
            then
                state="$profile.nginx"
            elif [ -f "salt/${dir_profile%/*}/nginx.sls" ]
            then
                state="${profile%.*}.nginx"
            fi
            if [ -n "$state" ]
            then
                echo "Applying $state ..." >> "$out"
                salt-call --local state.apply "$state" >> "$out" || rolestatus=1
                echo >> "$out"
                unset state
                break
            fi
        fi
    done
fi

echo 'Applying nginx ...' >> "$out"
salt-call --local state.apply nginx >> "$out" || rolestatus=1
mkdir /etc/ssl/services
create_fake_certs
touch_includes "$role"

printf '\nTesting configuration ...\n' >> "$out"
mispipe 'nginx -tq' "tee -a $out" || rolestatus=1

printf '\nDumping configuration ...\n' >> "$out"
nginx -T >> "$out"

# make sure all vhost config files are named *.conf (without that suffix, they get ignored)
for file in /etc/nginx/vhosts.d/* ; do
    test "$file" == "/etc/nginx/vhosts.d/*" && continue  # skip loop if no file exists in vhosts.d/
    echo "$file" | grep -q '\.conf$' || {
        echo "ERROR: $file is not named *.conf"
        rolestatus=1
    }
done

if test $rolestatus = 0; then
    echo_PASSED
else
    echo_FAILED
    head -n1000 /etc/nginx/vhosts.d/*
    echo "### end of /etc/nginx/vhosts.d/* for role $role"
    STATUS=1
fi
echo
echo "END OF $role" >> "$out"

rpm -qa --qf '%{name}\n' | sort > /tmp/packages-after

diff -U0 /tmp/packages-before /tmp/packages-after || echo '=== The packages listed above were installed by one of the roles. Consider to add them to the container image to speed up this test.'

exit "$STATUS"

# vim:expandtab
