jenkins_pkgs:
  pkg.installed:
    - pkgs:
      - jenkins-lts

jenkins_target:
  service.running:
    - name: jenkins.target
    - enable: True

jenkins_restart:
  module.wait:
    - name: service.restart
    - m_name: jenkins.target
    - require:
      - service: jenkins_target
