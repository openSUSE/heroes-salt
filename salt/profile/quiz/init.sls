include:
  - profile.systemd.daemon-reload

profile_quiz_directory:
  file.directory:
    - names:
        - /data/quiz
        - /data/quiz/stats
    - user: quiz
    - group: quiz

profile_quiz_repository:
  git.cloned:
    - name: https://github.com/openSUSE/quiz.git
    - target: /data/quiz/quiz-git
    - branch: main
    - user: quiz
    - require:
        - file: profile_quiz_directory

profile_quiz_tmpfiles:
  file.managed:
    - name: /etc/tmpfiles.d/quiz.conf
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - d /run/quiz 0751 quiz quiz
        - a+ /run/quiz - - - - d:u:nginx:rw

profile_quiz_tmpfiles_run:
  cmd.run:
    - name: systemd-tmpfiles --create /etc/tmpfiles.d/quiz.conf
    - onchanges:
        - file: profile_quiz_tmpfiles

profile_quiz_linger:
  cmd.run:
    - name: loginctl enable-linger quiz
    - creates: /var/lib/systemd/linger/quiz

profile_quiz_script:
  file.managed:
    - name: /home/quiz/bin/deploy-quizzes.py
    - source: salt://{{ slspath }}/files/deploy-quizzes.py.jinja
    - template: jinja
    - user: root
    - group: quiz
    - mode: '0750'

profile_quiz_unit_files:
  file.managed:
    - user: root
    - group: quiz
    - mode: '0644'
    - names:
        - /etc/systemd/system/quiz-update.service:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - '[Unit]'
                - Description=Update of Quiz instances
                - Documentation=https://github.com/openSUSE/quiz
                - ''
                - '[Service]'
                - Type=oneshot
                - User=quiz
                - Group=quiz
                - ExecStart=/home/quiz/bin/deploy-quizzes.py
                - SyslogIdentifier=%N
                - PrivateTmp=yes
                - ProtectSystem=strict
                - ReadWritePaths=/data/quiz/quiz-git
                - ReadWritePaths=/data/quiz/stats
                - ReadWritePaths=/run/quiz
        - /etc/systemd/system/quiz-update.timer:
            - contents:
                - {{ pillar['managed_by_salt'] | yaml_encode }}
                - '[Unit]'
                - Description=Scheduler for the update of Quiz instances
                - ''
                - '[Timer]'
                - AccuracySec=10
                - OnCalendar=*:0/30
                - OnStartupSec=0
                - ''
                - '[Install]'
                - WantedBy=timers.target

profile_quiz_unit_enable:
  service.running:
    - name: quiz-update.timer
    - enable: true
    - require:
        - module: systemd_reload_daemon
    - watch:
        - file: profile_quiz_unit_files

profile_quiz_podman_unit_enable:
  file.symlink:
    - name: /home/quiz/.config/systemd/user/sockets.target.wants/podman.socket
    - target: /usr/lib/systemd/user/podman.socket
    - makedirs: true

# this is not that useful as it only allows to check the web server and not the JS app, but better than nothing
profile_quiz_check_file:
  file.managed:
    - name: /srv/www/htdocs/check
    - contents:
        - ok

profile_quiz_502_file:
  file.managed:
    - name: /srv/www/htdocs/502.html
    - contents:
        - <html>
        - Sorry, but there's no quiz here.
        - </html>
