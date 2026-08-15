include:
  - mysql.server
  - profile.systemd.daemon-reload

profile_rmt_packages:
  pkg.installed:
    - name: rmt-server

profile_rmt_config:
  file.serialize:
    - name: /etc/rmt.conf
    - dataset_pillar: profile:rmt:config
    - serializer: yaml
    # permissions match what is shipped with the rmt-server package,
    # no idea why it needs to modify its own configuration
    - user: _rmt
    - group: root
    - mode: '0640'
    - require:
        - pkg: profile_rmt_packages

# very ugly, but what they officially instruct one to do in the rmt documentation!
# https://github.com/SUSE/rmt/issues/1545
profile_rmt_repo_link:
  file.symlink:
    - name: /usr/share/rmt/public/repo
    - target: /data/repo
    - force: true

profile_rmt_rmt-server-mirror_service:
  file.managed:
    - name: /etc/systemd/system/rmt-server-mirror.service.d/salt.conf
    - makedirs: True
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - '[Service]'
        # the service is shipped with ProtectSystem=full, but without allowing
        # writing to the hardcoded (see above) paths (this is surely a bug)
        - ReadWritePaths=/usr/share/rmt/public/suma
        # the program clutters /tmp with garbage, and does not clean up properly
        # https://github.com/SUSE/rmt/issues/875
        # (but this option is good to have either way)
        - PrivateTmp=yes

profile_rmt_rmt-server_service:
  service.running:
    - name: rmt-server
    - enable: true
    - watch:
        - file: profile_rmt_config
    - require:
        - file: profile_rmt_repo_link
        - pkg: profile_rmt_packages
        - service: mysqld-service-running

profile_rmt_rmt-server-mirror_timer:
  service.running:
    - name: rmt-server-mirror.timer
    - enable: true
    - require:
        - file: profile_rmt_rmt-server-mirror_service
        - file: profile_rmt_repo_link
        - module: systemd_reload_daemon
        - pkg: profile_rmt_packages
        - service: profile_rmt_rmt-server_service
