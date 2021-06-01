apparmor:
  profiles:
    httpd2-prefork:
      source: salt://profile/countdown/files/httpd2-prefork.apparmor
      template: jinja

profile:
  countdown:
    languages:
      - af
      - bg
      - cs
      - da
      - de
      - el
      - en
      - es
      - fi
      - fr
      - gl
      - hr
      - hu
      - id
      - it
      - ja
      - lt
      - nb
      - nl
      - pl
      - pt
      - pt_BR
      - ro
      - ru
      - sk
      - sv
      - tr
      - tw
      - wa
      - zh
    redirect_target: 'Portal:15.3'
