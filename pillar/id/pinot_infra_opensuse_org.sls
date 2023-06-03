grains:
  city: nuremberg
  country: de
  hostusage:
    - countdown.o.o, release-notes etc.
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: countdown.opensuse.org, board meeting reminder mailer, release notes, phpMyAdmin, asknot-ng
  documentation: []
  responsible:
    - cboltz
  partners: []
  weburls:
    - https://counter.opensuse.org
    - https://countdown.opensuse.org
    - https://doc.opensuse.org/release-notes/
    - https://pmya.opensuse.org
    - https://contribute.opensuse.org/
roles:
  - countdown
  - documentation
  - mail_reminder
  - phpmyadmin
  - asknot
