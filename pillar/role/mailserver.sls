include:
  - .common.mtail
{%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.mailserver
{%- endif %}

mtail:
  programs:
    - postfix

profile:
  mailserver:
    members:
      user: 'mbr_postfix'
  postfix:
    aliases:
      root: admin-auto@opensuse.org
    maincf:
      relayhost: ''
      recipient_delimiter: '+'
      smtpd_banner: '$myhostname ESMTP $mail_name ($mail_version)'
      delay_warning_time: '0h'
      inet_interfaces: {{ grains['fqdn_ip6'][0] }}
      mydestination: '$myhostname, localhost.$mydomain'
      myhostname: '{{ grains.host }}.opensuse.org'
      mynetworks: '[::1]/128, [2a07:de40:b27e:1201::]/64, [2a07:de40:b27e:1203::]/64, [2a07:de40:b27e:1204::]/64 [2a07:de40:b27e:1206::]/64 [2a07:de40:b27e:1102::]/64'
      mynetworks_style: 'subnet'
      alias_maps: ''
      canonical_maps: ''
      relocated_maps: ''
      transport_maps: 'lmdb:/etc/postfix/transport,lmdb:/etc/postfix/ratelimit'
      message_size_limit: 10000000
      strict_rfc821_envelopes: 'no'
      smtpd_client_restrictions: ''
      smtpd_helo_restrictions: ''
      smtpd_sender_restrictions: 'check_sender_access lmdb:/etc/postfix/manually-blocked-users,permit'
      smtpd_recipient_restrictions: >
        permit_mynetworks,
        reject_unauth_destination,
        reject_non_fqdn_sender,
        reject_non_fqdn_recipient,
        reject_unknown_sender_domain,
        reject_invalid_hostname,
        check_recipient_access pcre:/etc/postfix/bounce-old-mlmmj.pcre,
        check_helo_access pcre:/etc/postfix/greylist_helos.pcre,
        check_client_access pcre:/etc/postfix/suspicious_client.pcre,
        check_recipient_access lmdb:/etc/postfix/handling_special_recipients,
        reject_unlisted_recipient,
        permit
      smtp_sasl_auth_enable: 'no'
      smtp_use_tls: 'yes'
      smtp_tls_security_level: 'may'
      smtpd_tls_auth_only: 'yes'
      smtp_tls_loglevel: 1
      smtp_tls_CApath: '/etc/ssl/certs'
      smtpd_use_tls: 'yes'
      smtpd_tls_security_level: 'may'
      smtpd_tls_loglevel: 1
      smtpd_tls_CApath: /etc/ssl/certs
      {%- if grains['host'] == 'mx-test' %}
      {%- set certificate = 'mail-test.opensuse.org' %}
      {%- else %}
      {%- set certificate = 'mail.opensuse.org' %}
      {%- endif %}
      smtpd_tls_eccert_file: /etc/ssl/services/{{ certificate }}/fullchain.pem
      smtpd_tls_eckey_file: /etc/ssl/services/{{ certificate }}/privkey.pem
      # 20200709 I have some names in /etc/hosts that are needed
      smtp_host_lookup: 'native'
      # 20200708 see http://www.postfix.org/SMTPUTF8_README.html
      smtputf8_enable: 'no'
      smtpd_tls_received_header: 'yes'
      # 2021-09-16 updated by lrupp due to Vul-Scan report
      # used https://ssl-config.mozilla.org/#server=postfix&version=3.4.7&config=intermediate&openssl=1.1.1d&guideline=5.6
      # as reference for the configuration
      smtpd_tls_protocols: '!SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
      smtpd_tls_mandatory_protocols: '!SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
      smtp_tls_protocols: '!SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
      smtp_tls_mandatory_protocols: '!SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
      smtpd_tls_mandatory_ciphers: 'medium'
      tls_medium_cipherlist: 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384'  # noqa 204
      tls_preempt_cipherlist: 'no'

      # 20160303 forward secrecy
      smtpd_tls_dh1024_param_file: '/etc/postfix/dh2048.pem'
      smtpd_tls_dh512_param_file: '/etc/postfix/dh512.pem'
      smtpd_tls_eecdh_grade: 'strong'
      # 20200714 do not offer tls for internal connections.
      smtpd_discard_ehlo_keyword_address_maps: 'lmdb:/etc/postfix/no-internal-tls'
      smtpd_restriction_classes: 'greylist'
      greylist: 'check_policy_service unix:/var/spool/postfix/postgrey/socket'
      virtual_alias_domains: 'lmdb:/etc/postfix/virtual-domains'
      # please note:
      # the order of virtual alias lists is important. By keeping our "own" aliases
      # at the top, we make sure they are never overwritten by e.g. a user alias.
      virtual_alias_maps: >
        lmdb:/etc/postfix/virtual-opensuse-aliases,
        pcre:/etc/postfix/virtual-opensuse-mm3-bounces.pcre,
        lmdb:/etc/postfix/virtual-opensuse-users,
        lmdb:/etc/postfix/virtual-opensuse-mailinglists
      # amount of relay_domains must align with the "Postfix flush queue (MX)" alerting threshold in salt/files/prometheus/alerts/mail.yml
      relay_domains: 'code.opensuse.org,forums.opensuse.org,lists.opensuse.org,lists.uyuni-project.org'
      smtpcox_destination_concurrency_limit: 2
      smtpcox_destination_rate_delay: '615s'
      smtpcox_destination_recipient_limit: 10
      smtpcox_destination_concurrency_failed_cohort_limit: 10
      # postsrsd
      sender_canonical_maps: 'tcp:ipv6-localhost:10001'
      sender_canonical_classes: 'envelope_sender'
      recipient_canonical_maps: 'tcp:ipv6-localhost:10002'
      recipient_canonical_classes: 'envelope_recipient,header_recipient'
      # rspamd
      # smtpd_milters = unix:/run/rspamd/worker-proxy.socket
      header_checks: 'pcre:/etc/postfix/header_checks'
      # 20200805 enable soft_bounce during migration
      # 20200817 turning off soft_bounce
      # 20210328 turning back on
      # 20210401 back off
      soft_bounce: 'no'
      inet_protocols: all
      # https://progress.opensuse.org/issues/102617
      disable_vrfy_command: 'yes'

      smtpsud_destination_concurrency_limit: 1
      smtpsud_destination_rate_delay: 60s
      smtpsud_destination_recipient_limit: 1
      smtpsud_destination_concurrency_failed_cohort_limit: 10
      smtpbol_destination_concurrency_limit: 1
      smtpbol_destination_rate_delay: 1s
      smtpbol_destination_recipient_limit: 1
      smtpbol_destination_concurrency_failed_cohort_limit: 10
      # just a general slow rate
      smtpslow_destination_concurrency_limit: 1
      smtpslow_destination_rate_delay: 60s
      smtpslow_destination_recipient_limit: 1
      smtpslow_destination_concurrency_failed_cohort_limit: 10
      # poo#135779 gmail rate limit
      smtpv6o_destination_concurrency_limit: 1
      smtpv6o_destination_rate_delay: 1s
      smtpv6o_destination_recipient_limit: 1
      smtpv6o_destination_concurrency_failed_cohort_limit: 10


zypper:
  packages:
    jq: {}
    postsrsd: {}
    postgrey: {}
    clamav: {}
    spamassassin: {}
    perl-razor-agents: {}
    mailgraph: {}
    mariadb-client: {}
