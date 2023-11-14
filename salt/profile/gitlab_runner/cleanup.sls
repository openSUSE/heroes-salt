gitlab_runner_cleanup_files:
  file.managed:
    - names:
      - /usr/local/sbin/cleanup.sh:
        - source: salt://profile/gitlab_runner/files/usr/local/sbin/cleanup.sh.jinja
        - mode: '0755'
      {%- for unit in ['timer', 'service'] %}
      - /etc/systemd/system/docker-cleanup.{{ unit }}:
        - source: salt://profile/gitlab_runner/files/etc/systemd/system/docker-cleanup.{{ unit }}.jinja
        - mode: '0644'
      {%- endfor %}
    - template: jinja

gitlab_runner_cleanup_timer:
  service.running:
    - name: docker-cleanup.timer
    - enable: true
    - require:
      - file: gitlab_runner_cleanup_files
