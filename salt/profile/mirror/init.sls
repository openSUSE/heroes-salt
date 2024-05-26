include:
  - users
  - zypper.packages

mirror_bin:
  file.managed:
    - names:
        {%- for file in [
              'loop_common',
              'loop_repositories.sh',
              'loop_tumbleweed.sh',
              'loop_update.sh',
            ]
        %}
        - /home/mirror/bin/{{ file }}:
            - source: salt://{{ slspath }}/files/bin/{{ file }}.jinja
        {%- endfor %}
    - mode: '0750'
    - user: mirror
    - require:
        - user: user_mirror_user

mirror_cscreenrc:
  file.managed:
    - name: /etc/cscreenrc
    - contents: |
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - multiuser on
        - acladd admin root
        - startup_message off
        - termcapinfo xterm hs@
        - bind k
        - bind ^k
        - bind K
        - bind \
        - bind B break 3
        - logfile /var/log/screen/screenlog.%t.log
        - logtstamp on
        - logtstamp string "-- %n:%t -- time-stamp -- %Y-%m-%d %c:%s --\n"
        - deflog on
        - caption always "%3n %t%? @%u%?%? [%h]%?"
        - zombie "x "
        - log on
        - zombie_timeout 11
        - screen -L 0:sync_updates        bash --login -c "/home/mirror/bin/loop_update.sh"
        - screen -L 0:sync_tumbleweed     bash --login -c "/home/mirror/bin/loop_tumbleweed.sh"
        - screen -L 0:sync_repositories   bash --login -c "/home/mirror/bin/loop_repositories.sh"
    - create: false
    - require:
        - pkg: zypper_packages

mirror_cscreen_service:
  service.running:
    - name: cscreen
    - enable: true
    - watch:
        - file: mirror_cscreenrc
    - require:
        - file: mirror_bin
        - pkg: zypper_packages
