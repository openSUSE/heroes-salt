/etc/tukit.conf:
  file.managed:
    - source: salt://{{ slspath }}/files/etc/tukit.conf.jinja
    - template: jinja
