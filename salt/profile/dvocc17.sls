dvocc17_testdir:
  git.latest:
    - name: ssh://gitlab@gitlab.infra.opensuse.org/tbro/dvocc17-ci-test.git
    - target: /tmp/dvocc17
    - identity: /root/.ssh/id_rsa
    - user: root
    - branch: master
