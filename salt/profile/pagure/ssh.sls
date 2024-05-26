include:
  - profile.apparmor.local-overrides
  - zypper.packages

pagure_ssh_directory:
  file.directory:
    - name: /etc/ssh-public
    - mode: '0750'

pagure_ssh_config:
  file.managed:
    - name: /etc/ssh-public/sshd_config
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - Include /etc/ssh/sshd_config
        - ListenAddress ipv6-localhost:2222
        - AllowUsers git
        - Match User git
        -   AuthorizedKeysCommand /usr/lib/pagure/keyhelper.py "%u" "%h" "%t" "%f"
        -   AuthorizedKeysCommandUser git
    - require:
        - file: pagure_ssh_directory

pagure_ssh_unit:
  file.managed:
    - name: /etc/systemd/system/sshd-public.service
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Unit]'
        - Description=Public OpenSSH Daemon
        - After=network.target
        - ''
        - '[Service]'
        - Type=notify
        - Environment=CONFIG=/etc/ssh-public/sshd_config
        - ExecStartPre=/usr/sbin/sshd -tf $CONFIG
        - ExecStart=/usr/sbin/sshd -Df $CONFIG
        - ExecReload=/bin/kill -HUP $MAINPID
        - KillMode=process
        - Restart=on-failure
        - RestartPreventExitStatus=255
        - TasksMax=infinity
        - ''
        - '[Install]'
        - WantedBy=multi-user.target

pagure_ssh_service:
  service.running:
    - name: sshd-public
    - enable: true
    - reload: true
    - watch:
        - file: pagure_ssh_config
    - require:
        - file: pagure_ssh_unit

pagure_mmproxy_config:
  suse_sysconfig.sysconfig:
    - name: go-mmproxy
    - key_values:
        ARGS: >-
          -4 127.0.0.1:2222
          -6 [::1]:2222
          -l {{ grains['fqdn_ip6'][0] }}:2222
          -v 1
          --allowed-subnets /etc/go-mmproxy.subnets
    - require:
        - pkg: zypper_packages

pagure_mmproxy_networks:
  file.managed:
    - name: /etc/go-mmproxy.subnets
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - 2a07:de40:b27e:1204::11/128
        - 2a07:de40:b27e:1204::12/128

pagure_mmproxy_service:
  service.running:
    - name: go-mmproxy
    - enable: true
    - reload: false
    - watch:
        - suse_sysconfig: pagure_mmproxy_config
        - file: pagure_mmproxy_networks
        - file: apparmor_local_go-mmproxy
