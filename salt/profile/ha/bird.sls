include:
  - bird
  - keepalived
  - profile.systemd.daemon-reload

{%- set rundir = '/run/birdalived' %}
{%- set files = {
      'tmpfiles': '/etc/tmpfiles.d/birdalived.conf',
      'pipe-processor': '/usr/local/libexec/systemd/keepalived-pipe-processor.pl',
      'generate-bird-includes': '/usr/local/libexec/systemd/keepalived-generate-bird-includes.pl',
      'database': rundir ~ '/database',
      'output': salt['pillar.get']('bird:server:definitions:openSUSE_VRRP_Primary_Networks:include'),
} %}

profile_ha_bird_script_files:
  file.managed:
    - user: root
    - group: root
    - mode: '0755'
    - template: jinja
    - context:
        database: {{ files['database'] }}
        output: {{ files['output'] }}
        pipe: {{ salt['pillar.get']('keepalived:config:global_defs:vrrp_notify_fifo') }}
    - names:
        - {{ files['pipe-processor'] }}:
            - source: salt://{{ slspath }}/files/bird/keepalived-pipe-processor.pl.jinja
        - {{ files['generate-bird-includes'] }}:
            - source: salt://{{ slspath }}/files/bird/keepalived-generate-bird-includes.pl.jinja

profile_ha_bird_systemd_files:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - names:
        - {{ files['tmpfiles'] }}:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - d {{ rundir }} 0755 keepalived_script root
        - /etc/systemd/system/keepalived-pipe-processor.service:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - '[Unit]'
                - Description=Keepalived FIFO notification processor
                - After=keepalived.service
                # Keepalived deletes the pipe upon being stopped, prevent processor from failing after exhausting its opening attempts.
                # In case of a restart, the processor will be started again through Wants= in keepalived.service.
                - StopPropagatedFrom=keepalived.service
                - '[Service]'
                - User=keepalived_script
                - ExecStart={{ files['pipe-processor'] }}
                - ProtectSystem=strict
                - ReadWritePaths={{ rundir }}
                - '[Install]'
                - WantedBy=multi-user.target
        - /etc/systemd/system/bird.service.d/salt-ha.conf:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - '[Unit]'
                - Requires=bird-includes.service
            - makedirs: true
        - /etc/systemd/system/keepalived.service.d/salt-ha.conf:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - '[Unit]'
                # Start processor if feeder is, but without explicit ordering as processor waits for the pipe to be ready by itself.
                - Wants=keepalived-pipe-processor.service
            - makedirs: true
        - /etc/systemd/system/bird-includes.service:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - '[Unit]'
                - Description=BIRD network includes
                - After=keepalived-pipe-processor.service
                - Before=bird.service
                - Requisite=keepalived-pipe-processor.service
                - ConditionFileNotEmpty={{ files['database'] }}
                - '[Service]'
                - Type=oneshot
                - User=keepalived_script
                - ExecStartPre=-cp {{ files['output'] }} {{ files['output'] }}.pre
                - ExecStart={{ files['generate-bird-includes'] }}
                - >-
                    ExecStartPost=!sh -cx
                    'if ! diff {{ files['output'] }}{,.pre} && systemctl is-active -q bird;
                    then birdc configure check &&
                    birdc configure; fi'
                - LogLevelMax=notice
                - ProtectSystem=strict
                - ReadWritePaths={{ rundir }}
        - /etc/systemd/system/bird-includes.timer:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - '[Unit]'
                - Description=Scheduler for the generation of BIRD network includes
                - After=keepalived-pipe-processor.service
                - ''
                - '[Timer]'
                - AccuracySec=5
                - OnCalendar=*:*:0/10
                - ''
                - '[Install]'
                - WantedBy=timers.target

profile_ha_bird_tmpfiles_run:
  cmd.run:
    - name: systemd-tmpfiles --create {{ files['tmpfiles'] }}
    - onchanges:
        - file: {{ files['tmpfiles'] }}

profile_ha_bird_systemd_run_enable:
  service.running:
    - names:
        - keepalived-pipe-processor.service
        - bird-includes.timer
    - enable: true
    - require:
        - file: profile_ha_bird_script_files
        - file: profile_ha_bird_systemd_files
        - cmd: profile_ha_bird_tmpfiles_run
    - require_in:
        - service: bird_service
        - service: keepalived-service-running-service-running

# Service is normally only triggered by the timer, but upon changes here start it explicitly once before BIRD reloads with a missing or wrong include file.
profile_ha_bird_systemd_run:
  module.run:
    - service.start:
         - name: bird-includes.service
    - onchanges:
        - file: {{ files['generate-bird-includes'] }}
    - require:
        - service: profile_ha_bird_systemd_run_enable
    - require_in:
        - service: bird_service

# On new systems, Keepalived needs to be restarted first, as includes configured in BIRD depend on the named pipe initialized by Keepalived.
extend:
  bird_service:
    service:
      - require:
          - service: keepalived-service-running-service-running
