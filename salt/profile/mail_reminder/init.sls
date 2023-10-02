include:
  - profile.cron

mail_reminder_pkgs:
  pkg.installed:
    - pkgs:
      - git-core
      - python-base

mail_reminder:
    user.present:
    - createhome: False
    - home: /home/mail_reminder
    - shell: /bin/bash

/home/mail_reminder:
  file.directory:
    - user: mail_reminder

https://github.com/openSUSE/mail-reminder:
  git.cloned:
    - target: /home/mail_reminder/git
    - user: mail_reminder


mail_reminder_cron_mailto:
  cron.env_present:
    - name: MAILTO
    - value: admin-auto@opensuse.org
    - user: mail_reminder

'cd /home/mail_reminder/git/ && git pull -q':
  cron.present:
    - identifier: git_pull
    - user: mail_reminder
    - minute: 40
    - hour: 11

'/home/mail_reminder/git/mail-reminder --no-debug':
  cron.present:
    - identifier: mailer
    - user: mail_reminder
    - minute: 42
    - hour: 11
