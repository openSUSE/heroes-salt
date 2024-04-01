include:
  - .backends
  - .global
  - .defaults

apparmor:
  local:
    usr.sbin.haproxy:
      - /etc/haproxy/** r
      - /etc/ssl/services/* r
      - /etc/step/certs/* r
      - /usr/share/pki/trust/anchors/** r
      - capability dac_read_search
      - capability dac_override
      - /var/lib/haproxy/stats-{ro,rw}{,.*.{bak,tmp}} rwl  # noqa 206

zypper:
  packages:
    hatop: {}
    socat: {}
