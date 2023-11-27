#!/bin/bash
{{ pillar['managed_by_salt'] }}

export PROVIDER_UPDATE_DELAY="30"
export PDNS_HOST=http://chip.infra.opensuse.org:8080
export PDNS_KEY={{ pillar['profile']['dehydrated']['hook']['pdns_key'] }}
export PDNS_SERVER=localhost
export CRTUSER='cert'

update_opensuse() {
    CERTDIR="$(dirname $FULLCHAINFILE)"
    CERTNAME="$(basename $(dirname $FULLCHAINFILE))"

    FULLFILE="$CERTDIR/${CERTNAME}_full.pem"

    cat "$FULLCHAINFILE" "$KEYFILE" > "$FULLFILE"    # to make ACLs work on the HAProxy hosts

    for target in $(grep -oP "CERTIFICATE $DOMAIN TARGETS \K.*" /etc/dehydrated/our-domains.txt | jq -r '.[]')
    do
	echo "Deploying certificate to $target ..."
	if ping -q -c 1 "$target" >/dev/null
	then
		DESTFULLNAME="/etc/ssl/services/${CERTNAME}.pem"
		scp "$FULLFILE" "$CRTUSER@$host:$DESTFULLNAME"
		echo "Reloading HAProxy on $target ..."
	else
		echo "Cannot reach $target, unable to deploy certificate."
	fi
    done


}

deploy_challenge() {

    # This hook is called once for every domain that needs to be
    # validated, including any alternative names you may have listed.
    #
    # Parameters:
    # - DOMAIN
    #   The domain name (CN or subject alternative name) being
    #   validated.
    # - TOKEN_FILENAME
    #   The name of the file containing the token to be served for HTTP
    #   validation. Should be served by your web server as
    #   /.well-known/acme-challenge/${TOKEN_FILENAME}.
    # - TOKEN_VALUE
    #   The token value that needs to be served for validation. For DNS
    #   validation, this is what you want to put in the _acme-challenge
    #   TXT record. For HTTP validation it is the value that is expected
    #   be found in the $TOKEN_FILENAME file.
    # local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
    local chain=($@)
    echo "chain: $chain"
    for ((i=0; i < $#; i+=3)); do
      local DOMAIN="${chain[i]}" TOKEN_FILENAME="${chain[i+1]}" TOKEN_VALUE="${chain[i+2]}"

      echo "Trying to verify domain '${DOMAIN}' with '${TOKEN_FILENAME}' '${TOKEN_VALUE}'" 

      lexicon powerdns create ${DOMAIN} TXT \
        --name="_acme-challenge.${DOMAIN}." \
        --content="${TOKEN_VALUE}" \
        --auth-token="${PDNS_KEY}" \
        --pdns-server="${PDNS_HOST}" \
        --pdns-server-id="${PDNS_SERVER}"
    done
    sleep 30
}

clean_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.

    # /usr/sbin/pdns_api.sh clean_challenge "${DOMAIN}" "${TOKEN_FILENAME}" "${TOKEN_VALUE}"
    local chain=($@)
    for ((i=0; i < $#; i+=3)); do
        local DOMAIN="${chain[i]}" TOKEN_FILENAME="${chain[i+1]}" TOKEN_VALUE="${chain[i+2]}"

        echo "clean_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

        lexicon powerdns delete ${DOMAIN} TXT \
          --name="_acme-challenge.${DOMAIN}." \
          --content="${TOKEN_VALUE}" \
          --auth-token="${PDNS_KEY}" \
          --pdns-server="${PDNS_HOST}" \
          --pdns-server-id="${PDNS_SERVER}"
    done

}

deploy_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"

    # This hook is called once for each certificate that has been
    # produced. Here you might, for instance, copy your new certificates
    # to service-specific locations and reload the service.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).

    update_opensuse
}

unchanged_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    # This hook is called once for each certificate that is still
    # valid and therefore wasn't reissued.

    #update_opensuse
}

invalid_challenge() {
    local DOMAIN="${1}" RESPONSE="${2}"

    # This hook is called if the challenge response has failed, so domain
    # owners can be aware and act accordingly.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - RESPONSE
    #   The response that the verification server returned

    # Simple example: Send mail to root
    # printf "Subject: Validation of ${DOMAIN} failed!\n\nOh noez!" | sendmail root
}

request_failure() {
    local STATUSCODE="${1}" REASON="${2}" REQTYPE="${3}" HEADERS="${4}"

    # This hook is called when an HTTP request fails (e.g., when the ACME
    # server is busy, returns an error, etc). It will be called upon any
    # response code that does not start with '2'. Useful to alert admins
    # about problems with requests.
    #
    # Parameters:
    # - STATUSCODE
    #   The HTML status code that originated the error.
    # - REASON
    #   The specified reason for the error.
    # - REQTYPE
    #   The kind of request that was made (GET, POST...)

    # Simple example: Send mail to root
    # printf "Subject: HTTP request failed failed!\n\nA http request failed with status ${STATUSCODE}!" | sendmail root
}

generate_csr() {
    local DOMAIN="${1}" CERTDIR="${2}" ALTNAMES="${3}"

    # This hook is called before any certificate signing operation takes place.
    # It can be used to generate or fetch a certificate signing request with external
    # tools.
    # The output should be just the cerificate signing request formatted as PEM.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain as specified in domains.txt. This does not need to
    #   match with the domains in the CSR, it's basically just the directory name.
    # - CERTDIR
    #   Certificate output directory for this particular certificate. Can be used
    #   for storing additional files.
    # - ALTNAMES
    #   All domain names for the current certificate as specified in domains.txt.
    #   Again, this doesn't need to match with the CSR, it's just there for convenience.

    # Simple example: Look for pre-generated CSRs
    # if [ -e "${CERTDIR}/pre-generated.csr" ]; then
    #   cat "${CERTDIR}/pre-generated.csr"
    # fi
}

startup_hook() {
  # This hook is called before the cron command to do some initial tasks
  # (e.g. starting a webserver).

  :
}

exit_hook() {
  # This hook is called at the end of the cron command and can be used to
  # do some final (cleanup or other) tasks.

  :
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|deploy_cert|unchanged_cert|invalid_challenge|request_failure|generate_csr|startup_hook|exit_hook)$ ]]; then
  "$HANDLER" "$@"
fi
