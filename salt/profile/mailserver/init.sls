/etc/postfix/master.cf:
  file.managed:
    - source: salt://profile/mailserver/files/master.cf
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - replace: True
    - require:
      - pkg: postfix
    - watch_in:
      - service: postfix

{% for file in [
  'handling_special_recipients',
  'no-internal-tls',
  'ratelimit',
  'transport',
  'virtual-domains',
  'virtual-opensuse-aliases',
  'virtual-opensuse-mailinglists'
] %}
/etc/postfix/{{file}}:
  file.managed:
    - source: salt://profile/mailserver/files/{{file}}
    - user: root
    - group: root
    - mode: 0644
    - replace: True
  cmd.run:
    - name: postmap /etc/postfix/{{file}}
    - runas: root
    - onchanges:
      - file: /etc/postfix/{{file}}
    - watch_in:
      - service: postfix
    - require:
      - pkg: postfix
{% endfor %}

/etc/sysconfig/postgrey:
  file.line:
    - match: ^POSTGREY_EXTRA_OPTIONS=
    - content: POSTGREY_EXTRA_OPTIONS="--auto-whitelist-clients --greylist-text='Service temporarily unavailable, please retry later'"
    - mode: replace

/etc/postfix/header_checks:
  file.managed:
    - source: salt://profile/mailserver/files/header_checks
    - user: root
    - group: root
    - mode: 0644
    - replace: True 

{% for file in [
  'bounce-old-mlmmj.pcre',
  'greylist_helos.pcre',
  'suspicious_client.pcre',
  'virtual-opensuse-mm3-bounces.pcre'
] %}
/etc/postfix/{{file}}:
  file.managed:
    - source: salt://profile/mailserver/files/{{file}}
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - require:
      - pkg: postfix
    - watch_in:
      - service: postfix
{% endfor %}

/etc/clamd.conf:
  file.managed:
    - source: salt://profile/mailserver/files/clamd.conf
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - require:
      - pkg: clamav
    - watch_in:
      - service: clamd

/etc/freshclam.conf:
  file.managed:
    - source: salt://profile/mailserver/files/freshclam.conf
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - require:
      - pkg: clamav
    - watch_in:
      - service: freshclam

/etc/postgrey/whitelist_clients.local:
  file.managed:
    - source: salt://profile/mailserver/files/whitelist_clients.local
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - require:
      - pkg: postgrey
    - watch_in:
      - service: postgrey

{% for file, dir in [
  ('spampd', 'sysconfig'),
  ('local.cf', 'mail/spamassassin'),
  ('opensuse.cf', 'mail/spamassassin'),
  ('opensuse-rules.cf', 'mail/spamassassin'),
]%}
/etc/{{dir}}/{{file}}:
  file.managed:
    - source: salt://profile/mailserver/files/spamassassin/{{file}}
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - require:
      - pkg: spamassassin
    - watch_in:
      - service: spampd
{% endfor %}

spampd-in:
  host.present:
    - ip: 127.0.0.98

spampd-out:
  host.present:
    - ip: 127.0.0.99

postsrsd:
  host.present:
    - ip: 127.0.0.91

# MAYBE: remove override for clamd, seems to be standard now?
{% for svc in ['clamd', 'spampd'] %}
/etc/systemd/system/{{svc}}.service.d/override.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - makedirs: True
    - contents:
        - '[Service]'
        - 'RestartSec=10'
        - 'Restart=always'
{% endfor %}

{% for svc in ['clamd', 'freshclam', 'spampd', 'postsrsd', 'postgrey'] %}
service {{svc}}:
  service.running:
    - name: {{svc}}
    - enable: True
{% endfor %}

{% for file, dir in [
  ('dhprimes','/etc/cron.d'),
  ('regen_dh_primes','/usr/local/bin'),
  ('member_aliases','/etc/cron.d'),
  ('get_member_aliases', '/usr/local/bin')
]%}
{{dir}}/{{file}}:
  file.managed:
    - source: salt://profile/mailserver/files/cron/{{file}}
    - user: root
    - group: root
    - mode: {{ '0755' if dir.endswith('/bin') else '0644' }}
    - replace: True
{% endfor %}

