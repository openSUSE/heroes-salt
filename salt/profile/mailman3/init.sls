include:
  - profile.mailman3.mailman
  - profile.mailman3.config
  - profile.mailman3.master
  - .archrwr

mailman_service:
  service.running:
    - name: mailman
    - enable: True

mailman_web_service:
  service.running:
    - name: mailman-web.target
    - enable: True
