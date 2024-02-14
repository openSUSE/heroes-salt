keepalived:
  config:
    vrrp_script:
      check_haproxy_service:
        script: '"/usr/bin/systemctl is-active -q haproxy"'
        weight: 1
        interval: 10
        timeout: 2
      {#- always returns 1 if executed through keepalived but works fine if run via `sudo -u keepalived_script ...`
          re-enable when a solution is found
      check_haproxy_status:
        script: /usr/local/libexec/keepalived/check_haproxy.sh
        weight: 3
        interval: 5
        timeout: 3
      #}
  scripts:
    check_haproxy.sh:
      group: keepalived_script
      contents: |
        #!/bin/sh -fu
        # Managed by Salt
        SOCKET='/var/lib/haproxy/stats-ro'
        if [ -S "$SOCKET" ]
        then
          /usr/bin/echo 'show info' | /usr/bin/socat "$SOCKET" stdio | /usr/bin/grep -q 'Stopping: 0'
        else
          >&2 echo 'Dead socket'
          exit 1
        fi

users:
  keepalived_script:
    groups:
      - haproxy
