profile_forgejo_runner_cleanup_files:
  file.managed:
    - names:
      - /usr/local/sbin/cleanup.sh:
        - source: salt://profile/forgejo/files/usr/local/sbin/cleanup.sh.jinja
        - mode: '0755'
      {%- for unit in ['timer', 'service'] %}
      - /etc/systemd/system/docker-cleanup.{{ unit }}:
        - source: salt://profile/forgejo/files/etc/systemd/system/docker-cleanup.{{ unit }}.jinja
        - mode: '0644'
      {%- endfor %}
    - template: jinja

profile_forgejo_runner_cleanup_timer:
  service.running:
    - name: docker-cleanup.timer
    - enable: true
    - require:
      - file: profile_forgejo_runner_cleanup_files
